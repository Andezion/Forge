import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dyplom/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pose_detection/pose_detection.dart';
import 'package:video_player/video_player.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/personal_challenge.dart';
import '../widgets/rank_badge_widget.dart';

class PoseCameraScreen extends StatefulWidget {
  final PersonalChallenge? challenge;

  const PoseCameraScreen({super.key, this.challenge});

  @override
  State<PoseCameraScreen> createState() => _PoseCameraScreenState();
}

class _PoseCameraScreenState extends State<PoseCameraScreen>
    with WidgetsBindingObserver {
  static const int _maxDim = 640;
  static const double _visibilityThreshold = 0.5;

  List<CameraDescription> _cameras = const [];
  CameraController? _controller;
  CameraLensDirection _lens = CameraLensDirection.front;
  bool _isSwitching = false;
  String? _cameraError;

  PoseDetector? _detector;
  bool _detectorReady = false;
  bool _frameInFlight = false;
  List<Pose> _poses = const [];
  Size? _imageSize;

  int _framesThisSecond = 0;
  int _fps = 0;
  Timer? _fpsTimer;

  bool _isRecording = false;
  bool _recordingBusy = false;
  final Stopwatch _recordWatch = Stopwatch();
  Timer? _recordTicker;

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
    _recordTicker?.cancel();
    _disposeController();
    _detector?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      () async {
        if (_isRecording) await _stopRecording(showReview: false);
        await _disposeController();
        if (mounted) setState(() {});
      }();
    } else if (state == AppLifecycleState.resumed && _controller == null) {
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
    } catch (e) {
      debugPrint('Pose CompiledModel init failed, using Interpreter: $e');
      try {
        detector = await PoseDetector.create(
          landmarkModel: PoseLandmarkModel.full,
        );
      } catch (e) {
        debugPrint('Pose detector init failed: $e');
      }
    }
    if (!mounted) {
      await detector?.dispose();
      return;
    }
    setState(() {
      _detector = detector;
      _detectorReady = detector != null;
    });
  }

  Future<void> _onFrame(CameraImage image) async {
    final detector = _detector;
    final controller = _controller;
    if (!_detectorReady || detector == null || controller == null) return;
    
    if (_frameInFlight) return;
    _frameInFlight = true;
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

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
    } on CameraException catch (e) {
      _setCameraError(e);
      return;
    }
    if (_cameras.isEmpty) {
      if (mounted) {
        setState(() =>
            _cameraError = AppLocalizations.of(context)!.poseNoCamera);
      }
      return;
    }
    if (!_cameras.any((c) => c.lensDirection == _lens)) {
      _lens = _cameras.first.lensDirection;
    }
    await _startCamera();
  }

  Future<void> _startCamera() async {
    if (_cameras.isEmpty) return;
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
      _setCameraError(e);
    }
  }

  void _setCameraError(CameraException e) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final denied = e.code.startsWith('CameraAccessDenied') ||
        e.code == 'CameraAccessRestricted';
    setState(() {
      _cameraError = denied
          ? l10n.poseCameraPermissionDenied
          : l10n.poseCameraError(e.description ?? e.code);
    });
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
    if (_isSwitching || _isRecording || !_canSwitch) return;
    setState(() => _isSwitching = true);
    _lens = _isFront ? CameraLensDirection.back : CameraLensDirection.front;
    await _disposeController();
    await _startCamera();
    if (mounted) setState(() => _isSwitching = false);
  }

  Future<void> _toggleRecording() =>
      _isRecording ? _stopRecording() : _startRecording();

  Future<void> _startRecording() async {
    final c = _controller;
    if (c == null || _recordingBusy || _isRecording) return;
    _recordingBusy = true;
    try {
      if (c.value.isStreamingImages) await c.stopImageStream();
      try {
        await c.startVideoRecording(onAvailable: _onFrame);
      } on CameraException catch (e) {
        debugPrint('Record with stream failed, recording without: $e');
        await c.startVideoRecording();
      }
      _recordWatch
        ..reset()
        ..start();
      _recordTicker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
      if (mounted) setState(() => _isRecording = true);
    } on CameraException catch (e) {
      _setCameraError(e);
    } finally {
      _recordingBusy = false;
    }
  }

  Future<void> _stopRecording({bool showReview = true}) async {
    final c = _controller;
    if (c == null || _recordingBusy || !_isRecording) return;
    _recordingBusy = true;
    _recordTicker?.cancel();
    _recordWatch.stop();
    XFile? raw;
    try {
      raw = await c.stopVideoRecording(); 
    } on CameraException catch (e) {
      _setCameraError(e);
    }
    if (mounted) setState(() => _isRecording = false);
    _recordingBusy = false;

    if (showReview && _controller == c && !c.value.isStreamingImages) {
      try {
        await c.startImageStream(_onFrame);
      } catch (_) {}
    }

    if (raw == null) return;
    final saved = await _persistRecording(raw);
    if (!showReview || !mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RecordingReviewSheet(file: saved),
    );
  }

  Future<File> _persistRecording(XFile raw) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/challenge_videos');
    if (!await dir.exists()) await dir.create(recursive: true);
    final prefix = widget.challenge?.id ?? 'free';
    final ext = raw.path.contains('.') ? raw.path.split('.').last : 'mp4';
    final target =
        File('${dir.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.$ext');
    final source = File(raw.path);
    try {
      return await source.rename(target.path);
    } on FileSystemException {
      final copy = await source.copy(target.path);
      await source.delete();
      return copy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final challenge = widget.challenge;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          challenge == null
              ? l10n.poseCameraTitle
              : '${l10n.exercisePushUps} · ${l10n.repsCount(challenge.targetReps)}',
          style: AppTextStyles.h4.copyWith(color: Colors.white),
        ),
        actions: [
          if (_canSwitch)
            IconButton(
              tooltip: l10n.poseSwitchCamera,
              icon: const Icon(Icons.cameraswitch),
              onPressed: _isSwitching || _isRecording ? null : _switchCamera,
            ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildPreview(l10n),
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: _buildTopPanel(l10n),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24 + MediaQuery.of(context).padding.bottom,
            child: _buildBottomControls(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(AppLocalizations l10n) {
    if (_cameraError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            _cameraError!,
            textAlign: TextAlign.center,
            style: AppTextStyles.body1.copyWith(color: Colors.white70),
          ),
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

  Widget _buildTopPanel(AppLocalizations l10n) {
    final challenge = widget.challenge;
    final visible = _poses.isEmpty
        ? 0
        : _poses.first.landmarks
            .where((l) => l.visibility > _visibilityThreshold)
            .length;

    final String status;
    if (!_detectorReady) {
      status = l10n.poseLoadingModel;
    } else if (_poses.isEmpty) {
      status = l10n.poseNoPerson;
    } else {
      status = l10n.poseLandmarksVisible(visible);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          if (challenge != null) ...[
            RankBadgeWidget(rank: challenge.tier, size: 40),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (challenge != null)
                  Text(
                    '— / ${challenge.targetReps}',
                    style: AppTextStyles.h3.copyWith(color: Colors.white),
                  ),
                Text(
                  status,
                  style: AppTextStyles.body2.copyWith(color: Colors.white),
                ),
                if (challenge != null)
                  Text(
                    l10n.poseRepCounterSoon,
                    style: AppTextStyles.caption
                        .copyWith(color: Colors.white60),
                  ),
              ],
            ),
          ),
          if (_detectorReady)
            Text(
              '$_fps FPS',
              style: AppTextStyles.caption.copyWith(color: Colors.white70),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(AppLocalizations l10n) {
    final enabled = _controller != null && !_isSwitching && !_recordingBusy;
    final elapsed = _recordWatch.elapsed;
    final mm = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isRecording)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '● $mm:$ss',
              style: AppTextStyles.body2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Semantics(
          button: true,
          label: _isRecording ? l10n.poseStopRecording : l10n.poseStartRecording,
          child: GestureDetector(
            onTap: enabled ? _toggleRecording : null,
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
                  borderRadius: BorderRadius.circular(_isRecording ? 8 : 40),
                ),
                margin: EdgeInsets.all(_isRecording ? 14 : 0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecordingReviewSheet extends StatefulWidget {
  final File file;

  const _RecordingReviewSheet({required this.file});

  @override
  State<_RecordingReviewSheet> createState() => _RecordingReviewSheetState();
}

class _RecordingReviewSheetState extends State<_RecordingReviewSheet> {
  late final VideoPlayerController _player;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _player = VideoPlayerController.file(widget.file);
    _player.initialize().then((_) {
      if (!mounted) return;
      _player
        ..setLooping(true)
        ..play();
      setState(() => _ready = true);
    }).catchError((Object e) {
      debugPrint('Playback init failed: $e');
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottom = MediaQuery.of(context).padding.bottom;
    final maxVideoHeight = MediaQuery.of(context).size.height * 0.55;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.poseRecordingSaved, style: AppTextStyles.h3),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxVideoHeight),
            child: _ready
                ? GestureDetector(
                    onTap: () => setState(() {
                      _player.value.isPlaying ? _player.pause() : _player.play();
                    }),
                    child: AspectRatio(
                      aspectRatio: _player.value.aspectRatio,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: VideoPlayer(_player),
                      ),
                    ),
                  )
                : const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.poseDeleteRecording),
                  onPressed: () async {
                    await _player.pause();
                    try {
                      await widget.file.delete();
                    } catch (_) {}
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: Text(l10n.poseKeepRecording),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
