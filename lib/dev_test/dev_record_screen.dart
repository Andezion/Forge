import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pose_detection/pose_detection.dart';

import 'dev_recording.dart';
import 'dev_review_screen.dart';

class DevRecordScreen extends StatefulWidget {
  final DevExercise exercise;
  final DevCameraView view;
  final int countdownSeconds;

  const DevRecordScreen({
    super.key,
    required this.exercise,
    required this.view,
    this.countdownSeconds = 5,
  });

  @override
  State<DevRecordScreen> createState() => _DevRecordScreenState();
}

class _DevRecordScreenState extends State<DevRecordScreen>
    with WidgetsBindingObserver {
  static const int _maxDim = 640;

  List<CameraDescription> _cameras = const [];
  CameraController? _controller;
  CameraLensDirection _lens = CameraLensDirection.front;
  bool _cameraStarting = false;
  bool _isSwitching = false;
  String? _cameraError;

  PoseDetector? _detector;
  bool _frameInFlight = false;
  List<Pose> _poses = const [];
  Size? _imageSize;
  int _framesThisSecond = 0;
  int _fps = 0;
  Timer? _fpsTimer;

  int? _countdown;
  Timer? _countdownTimer;
  bool _isRecording = false;
  bool _busy = false;
  final Stopwatch _watch = Stopwatch();
  final List<LandmarkFrame> _frames = [];
  Size? _recordImageSize;

  bool get _isFront => _lens == CameraLensDirection.front;
  bool get _canSwitch =>
      _cameras.any((c) => c.lensDirection == CameraLensDirection.front) &&
      _cameras.any((c) => c.lensDirection == CameraLensDirection.back);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _fps = _framesThisSecond;
        _framesThisSecond = 0;
      });
    });
    _initDetector();
    _initCameras();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _fpsTimer?.cancel();
    _countdownTimer?.cancel();
    _disposeController();
    _detector?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _cancelCountdown();
      () async {
        if (_isRecording) await _stopRecording(openReview: false);
        await _disposeController();
        if (mounted) setState(() {});
      }();
    } else if (state == AppLifecycleState.resumed &&
        _controller == null &&
        !_cameraStarting) {
      _startCamera();
    }
  }

  Future<void> _initDetector() async {
    PoseDetector? detector;
    try {
      detector = await PoseDetector.create(
        landmarkModel: PoseLandmarkModel.full,
        useCompiledModel: true,
        precision: Precision.fp16,
      );
    } catch (_) {
      try {
        detector =
            await PoseDetector.create(landmarkModel: PoseLandmarkModel.full);
      } catch (e) {
        debugPrint('Pose detector init failed: $e');
      }
    }
    if (!mounted) {
      await detector?.dispose();
      return;
    }
    setState(() => _detector = detector);
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
    } on CameraException catch (e) {
      if (mounted) setState(() => _cameraError = e.description ?? e.code);
      return;
    }
    if (_cameras.isEmpty) {
      if (mounted) setState(() => _cameraError = 'Камера не найдена');
      return;
    }
    if (!_cameras.any((c) => c.lensDirection == _lens)) {
      _lens = _cameras.first.lensDirection;
    }
    await _startCamera();
  }

  Future<void> _startCamera() async {
    if (_cameras.isEmpty || _cameraStarting) return;
    _cameraStarting = true;
    final description = _cameras.firstWhere(
      (c) => c.lensDirection == _lens,
      orElse: () => _cameras.first,
    );
    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    try {
      await controller.initialize();
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _cameraError = null;
        _poses = const [];
        _imageSize = null;
      });
      await controller.startImageStream(_onFrame);
    } on CameraException catch (e) {
      await controller.dispose();
      if (mounted) setState(() => _cameraError = e.description ?? e.code);
    } finally {
      _cameraStarting = false;
    }
  }

  Future<void> _disposeController() async {
    final c = _controller;
    _controller = null;
    if (c == null) return;
    try {
      if (c.value.isStreamingImages) await c.stopImageStream();
    } catch (_) {}
    await c.dispose();
  }

  Future<void> _switchCamera() async {
    if (_isSwitching || _isRecording || _countdown != null || !_canSwitch) {
      return;
    }
    setState(() => _isSwitching = true);
    _lens = _isFront ? CameraLensDirection.back : CameraLensDirection.front;
    await _disposeController();
    await _startCamera();
    if (mounted) setState(() => _isSwitching = false);
  }

  Future<void> _onFrame(CameraImage image) async {
    final detector = _detector;
    final controller = _controller;
    if (detector == null || controller == null || _frameInFlight) return;
    _frameInFlight = true;
    final recording = _isRecording;
    final t = _watch.elapsedMilliseconds;
    try {
      final rotation = rotationForFrame(
        width: image.width,
        height: image.height,
        sensorOrientation: controller.description.sensorOrientation,
        isFrontCamera: _isFront,
        deviceOrientation: DeviceOrientation.portraitUp,
      );
      final size = detectionSize(
        width: image.width,
        height: image.height,
        rotation: rotation,
        maxDim: _maxDim,
      );
      final poses = await detector.detectFromCameraImage(
        image,
        rotation: rotation,
        maxDim: _maxDim,
      );
      _framesThisSecond++;
      if (recording && _isRecording) {
        _recordImageSize ??= size;
        _frames.add(LandmarkFrame(
          t,
          poses.isEmpty ? null : LandmarkFrame.fromPose(poses.first),
        ));
      }
      if (mounted) {
        setState(() {
          _poses = poses;
          _imageSize = size;
        });
      }
    } catch (e) {
      debugPrint('Pose frame failed: $e');
    } finally {
      _frameInFlight = false;
    }
  }

  void _onRecordButton() {
    if (_busy) return;
    if (_isRecording) {
      _stopRecording();
    } else if (_countdown != null) {
      _cancelCountdown();
    } else {
      _startCountdown();
    }
  }

  void _startCountdown() {
    setState(() => _countdown = widget.countdownSeconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      final next = (_countdown ?? 1) - 1;
      if (next <= 0) {
        timer.cancel();
        setState(() => _countdown = null);
        HapticFeedback.heavyImpact();
        _startRecording();
      } else {
        SystemSound.play(SystemSoundType.click);
        setState(() => _countdown = next);
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    if (mounted && _countdown != null) setState(() => _countdown = null);
  }

  Future<void> _startRecording() async {
    final c = _controller;
    if (c == null || _busy || _isRecording) return;
    _busy = true;
    try {
      if (c.value.isStreamingImages) await c.stopImageStream();
      _frames.clear();
      _recordImageSize = null;
      await c.startVideoRecording(onAvailable: _onFrame);
      _watch
        ..reset()
        ..start();
      if (mounted) setState(() => _isRecording = true);
    } on CameraException catch (e) {
      if (mounted) setState(() => _cameraError = e.description ?? e.code);
    } finally {
      _busy = false;
    }
  }

  Future<void> _stopRecording({bool openReview = true}) async {
    final c = _controller;
    if (c == null || _busy || !_isRecording) return;
    _busy = true;
    _watch.stop();
    XFile? raw;
    try {
      raw = await c.stopVideoRecording();
    } on CameraException catch (e) {
      debugPrint('Stop recording failed: $e');
    }
    if (mounted) setState(() => _isRecording = false);
    _busy = false;

    final size = _recordImageSize ?? _imageSize;
    if (_frames.isEmpty || size == null) {
      if (raw != null) {
        try {
          await File(raw.path).delete();
        } catch (_) {}
      }
      _showSnack('Нет кадров с распознаванием — запись отброшена');
      _resumeStream();
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final recording = DevRecording(
      id: id,
      exercise: widget.exercise,
      view: widget.view,
      lens: _isFront ? 'front' : 'back',
      createdAt: DateTime.now(),
      imageWidth: size.width.round(),
      imageHeight: size.height.round(),
      frames: List.of(_frames),
    );
    if (raw != null) {
      recording.videoFileName = await DevRecordingStore.importVideo(id, raw.path);
    }
    await DevRecordingStore.save(recording);

    if (!openReview || !mounted) return;
    await _disposeController();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => DevReviewScreen(recording: recording),
    ));
  }

  Future<void> _resumeStream() async {
    final c = _controller;
    if (c == null || c.value.isStreamingImages) return;
    try {
      await c.startImageStream(_onFrame);
    } catch (_) {}
  }

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${widget.exercise.label} · ${widget.view.label}'),
        actions: [
          if (_canSwitch)
            IconButton(
              icon: const Icon(Icons.cameraswitch),
              onPressed: _isRecording || _countdown != null || _isSwitching
                  ? null
                  : _switchCamera,
            ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildPreview(),
          Positioned(top: 12, left: 16, right: 16, child: _buildInfo()),
          if (_countdown != null)
            Center(
              child: Text(
                '$_countdown',
                style: const TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 12)],
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24 + MediaQuery.of(context).padding.bottom,
            child: Center(child: _buildRecordButton()),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_cameraError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(_cameraError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70)),
        ),
      );
    }
    final c = _controller;
    if (c == null || !c.value.isInitialized || _isSwitching) {
      return const Center(child: CircularProgressIndicator());
    }
    return CameraPoseOverlay(
      cameraPreview: CameraPreview(c),
      cameraAspectRatio: c.value.aspectRatio,
      displayAspectRatio: 1 / c.value.aspectRatio,
      mirrorHorizontally: Platform.isAndroid && _isFront,
      sensorOrientation: c.description.sensorOrientation,
      deviceOrientation: Orientation.portrait,
      isFrontCamera: _isFront,
      poses: _poses,
      imageSize: _imageSize,
    );
  }

  Widget _buildInfo() {
    final visible = _poses.isEmpty
        ? 0
        : _poses.first.landmarks.where((l) => l.visibility > 0.5).length;
    final lines = <String>[
      if (_detector == null) 'Загрузка модели…',
      if (_detector != null)
        _poses.isEmpty ? 'Человек не найден' : 'Видно точек: $visible / 33',
      '$_fps FPS',
      if (_isRecording)
        '● REC ${(_watch.elapsedMilliseconds / 1000).toStringAsFixed(0)} c · кадров: ${_frames.length}',
      if (!_isRecording && _countdown == null)
        'Нажми запись — будет отсчёт ${widget.countdownSeconds} c',
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        lines.join('\n'),
        style: const TextStyle(color: Colors.white, height: 1.4),
      ),
    );
  }

  Widget _buildRecordButton() {
    final enabled = _controller != null && !_isSwitching && !_busy;
    final active = _isRecording || _countdown != null;
    return GestureDetector(
      onTap: enabled ? _onRecordButton : null,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        padding: const EdgeInsets.all(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: enabled ? Colors.red : Colors.red.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(active ? 8 : 40),
          ),
          margin: EdgeInsets.all(active ? 14 : 0),
        ),
      ),
    );
  }
}
