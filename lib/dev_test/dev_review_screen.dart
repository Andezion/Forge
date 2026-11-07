import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pose_detection/pose_detection.dart';
import 'package:video_player/video_player.dart';

import '../services/pose_geometry.dart';
import 'dev_recording.dart';

const _metricColors = [Colors.orange, Colors.lightBlue, Colors.pink];

class DevReviewScreen extends StatefulWidget {
  final DevRecording recording;

  const DevReviewScreen({super.key, required this.recording});

  @override
  State<DevReviewScreen> createState() => _DevReviewScreenState();
}

class _DevReviewScreenState extends State<DevReviewScreen> {
  DevRecording get _r => widget.recording;

  VideoPlayerController? _player;
  bool _videoReady = false;

  Timer? _ticker;
  bool _skeletonPlaying = false;

  int _posMs = 0;
  int _offsetMs = 0;
  late bool _mirror = _r.lens == 'front';
  bool _saving = false;

  late final Map<JointAngleSpec, List<FlSpot>> _series = {
    for (final spec in _r.exercise.metrics)
      spec: [
        for (final f in _r.frames)
          if (f.lm == null)
            FlSpot.nullSpot
          else
            switch (measureAngle(f.lm!, spec)) {
              null => FlSpot.nullSpot,
              final a => FlSpot(f.t / 1000, a),
            },
      ],
  };

  int get _durationMs {
    final v = _player?.value;
    if (_videoReady && v != null && v.duration.inMilliseconds > 0) {
      return v.duration.inMilliseconds;
    }
    return _r.durationMs;
  }

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    final file = await DevRecordingStore.videoFile(_r);
    if (file == null || !mounted) return;
    final player = VideoPlayerController.file(file);
    _player = player;
    try {
      await player.initialize();
      await player.setLooping(true);
      player.addListener(_onVideoTick);
      if (mounted) setState(() => _videoReady = true);
    } catch (e) {
      debugPrint('Video init failed: $e');
    }
  }

  void _onVideoTick() {
    final ms = _player?.value.position.inMilliseconds ?? 0;
    if (mounted && ms != _posMs) setState(() => _posMs = ms);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _player?.removeListener(_onVideoTick);
    _player?.dispose();
    super.dispose();
  }

  bool get _isPlaying =>
      _videoReady ? _player!.value.isPlaying : _skeletonPlaying;

  void _togglePlay() {
    if (_videoReady) {
      final p = _player!;
      p.value.isPlaying ? p.pause() : p.play();
      setState(() {});
      return;
    }
    if (_skeletonPlaying) {
      _ticker?.cancel();
      setState(() => _skeletonPlaying = false);
    } else {
      _ticker = Timer.periodic(const Duration(milliseconds: 33), (_) {
        if (!mounted) return;
        setState(() {
          _posMs += 33;
          if (_posMs > _durationMs) _posMs = 0;
        });
      });
      setState(() => _skeletonPlaying = true);
    }
  }

  void _seek(double ms) {
    final v = ms.round();
    if (_videoReady) _player!.seekTo(Duration(milliseconds: v));
    setState(() => _posMs = v);
  }

  Future<void> _approve() async {
    final result = await showDialog<_ApproveResult>(
      context: context,
      builder: (_) => const _ApproveDialog(),
    );
    if (result == null) return;
    setState(() => _saving = true);
    _player?.pause();
    _r
      ..status = DevRecordingStatus.approved
      ..totalReps = result.total
      ..correctReps = result.correct
      ..note = result.note;
    await DevRecordingStore.deleteVideo(_r);
    await DevRecordingStore.save(_r);
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_r.status == DevRecordingStatus.pending
            ? 'Не подходит?'
            : 'Удалить запись?'),
        content: const Text('Видео и точки будут удалены.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Удалить')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _saving = true);
    _player?.pause();
    await DevRecordingStore.delete(_r);
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final frame = _r.frameAt(_posMs + _offsetMs);
    final maxH = MediaQuery.of(context).size.height * 0.45;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_r.exercise.label} · ${_r.view.label}'),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, 24 + MediaQuery.of(context).padding.bottom),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH),
              child: AspectRatio(
                aspectRatio: _r.imageWidth / _r.imageHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_videoReady)
                        FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _player!.value.size.width,
                            height: _player!.value.size.height,
                            child: VideoPlayer(_player!),
                          ),
                        )
                      else
                        const ColoredBox(color: Colors.black87),
                      CustomPaint(
                        painter: _SkeletonPainter(
                          lm: frame?.lm,
                          imageWidth: _r.imageWidth.toDouble(),
                          imageHeight: _r.imageHeight.toDouble(),
                          mirror: _mirror,
                        ),
                      ),
                      Positioned(
                        left: 8,
                        top: 8,
                        child: _AngleBadge(
                          lines: [
                            for (final spec in _r.exercise.metrics)
                              '${spec.label}: ${_fmtAngle(frame?.lm, spec)}',
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: _togglePlay,
              ),
              Expanded(
                child: Slider(
                  value: _posMs.clamp(0, _durationMs).toDouble(),
                  max: _durationMs.toDouble().clamp(1, double.infinity),
                  onChanged: _seek,
                ),
              ),
              Text('${(_posMs / 1000).toStringAsFixed(1)} c'),
            ],
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Зеркально'),
                selected: _mirror,
                onSelected: (v) => setState(() => _mirror = v),
              ),
              if (_videoReady) ...[
                const Text('Сдвиг скелета:'),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => setState(() => _offsetMs -= 50),
                ),
                Text('$_offsetMs мс'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => _offsetMs += 50),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(height: 220, child: _buildChart()),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            children: [
              for (final (i, spec) in _r.exercise.metrics.indexed)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 12,
                      height: 12,
                      color: _metricColors[i % _metricColors.length]),
                  const SizedBox(width: 6),
                  Text(spec.label),
                ]),
            ],
          ),
          const SizedBox(height: 16),
          _buildStats(),
          const SizedBox(height: 20),
          if (_saving)
            const Center(child: CircularProgressIndicator())
          else if (_r.status == DevRecordingStatus.pending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('Не подходит'),
                    onPressed: _delete,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Подходит'),
                    onPressed: _approve,
                  ),
                ),
              ],
            )
          else
            OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: const Text('Удалить запись'),
              onPressed: _delete,
            ),
        ],
      ),
    );
  }

  String _fmtAngle(List<double>? lm, JointAngleSpec spec) {
    if (lm == null) return '—';
    final a = measureAngle(lm, spec);
    return a == null ? '—' : '${a.round()}°';
  }

  Widget _buildChart() {
    final maxX = (_durationMs / 1000).clamp(0.1, double.infinity);
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: 0,
        maxY: 180,
        lineTouchData: const LineTouchData(enabled: false),
        clipData: const FlClipData.all(),
        gridData: const FlGridData(horizontalInterval: 30),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: 30,
              getTitlesWidget: (v, _) =>
                  Text('${v.round()}°', style: const TextStyle(fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: maxX > 20 ? 5 : 2,
              getTitlesWidget: (v, _) =>
                  Text('${v.round()}', style: const TextStyle(fontSize: 10)),
            ),
          ),
        ),
        extraLinesData: ExtraLinesData(verticalLines: [
          VerticalLine(
            x: ((_posMs + _offsetMs) / 1000).clamp(0, maxX).toDouble(),
            color: Colors.red,
            strokeWidth: 1.5,
          ),
        ]),
        lineBarsData: [
          for (final (i, spec) in _r.exercise.metrics.indexed)
            LineChartBarData(
              spots: _series[spec]!,
              color: _metricColors[i % _metricColors.length],
              barWidth: 2,
              dotData: const FlDotData(show: false),
            ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final lines = <String>[
      'Длительность: ${(_r.durationMs / 1000).toStringAsFixed(1)} c',
      'Кадров: ${_r.frames.length} (~${_r.avgFps.toStringAsFixed(1)} FPS)',
      'Человек найден: ${(_r.detectedRatio * 100).round()}% кадров',
      'Кадр детекции: ${_r.imageWidth}×${_r.imageHeight}, камера: ${_r.lens}',
      for (final spec in _r.exercise.metrics) _rangeLine(spec),
      if (_r.status == DevRecordingStatus.approved)
        'Повторов: ${_r.totalReps ?? '?'}, верных: ${_r.correctReps ?? '?'}',
      if ((_r.note ?? '').isNotEmpty) 'Заметка: ${_r.note}',
    ];
    return Text(lines.join('\n'), style: const TextStyle(height: 1.5));
  }

  String _rangeLine(JointAngleSpec spec) {
    final ys = _series[spec]!.where((s) => !s.isNull()).map((s) => s.y);
    if (ys.isEmpty) return '${spec.label}: нет данных';
    final min = ys.reduce((a, b) => a < b ? a : b);
    final max = ys.reduce((a, b) => a > b ? a : b);
    return '${spec.label}: ${min.round()}° … ${max.round()}°';
  }
}

class _AngleBadge extends StatelessWidget {
  final List<String> lines;
  const _AngleBadge({required this.lines});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        lines.join('\n'),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }
}

class _SkeletonPainter extends CustomPainter {
  final List<double>? lm;
  final double imageWidth;
  final double imageHeight;
  final bool mirror;

  _SkeletonPainter({
    required this.lm,
    required this.imageWidth,
    required this.imageHeight,
    required this.mirror,
  });

  static const _bones = [
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
    [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
    [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
    [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
    [PoseLandmarkType.leftAnkle, PoseLandmarkType.leftFootIndex],
    [PoseLandmarkType.rightAnkle, PoseLandmarkType.rightFootIndex],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final data = lm;
    if (data == null) return;
    final sx = size.width / imageWidth;
    final sy = size.height / imageHeight;

    Offset? point(PoseLandmarkType t) {
      final i = t.index * kLandmarkStride;
      if (data[i + 3] < 0.5) return null;
      final x = data[i] * sx;
      return Offset(mirror ? size.width - x : x, data[i + 1] * sy);
    }

    final bone = Paint()
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final b in _bones) {
      final a = point(b[0]), c = point(b[1]);
      if (a == null || c == null) continue;
      bone.color = b[0].name.startsWith('left')
          ? Colors.greenAccent
          : Colors.cyanAccent;
      canvas.drawLine(a, c, bone);
    }
    final dot = Paint()..color = Colors.redAccent;
    for (final t in PoseLandmarkType.values) {
      if (t.index < PoseLandmarkType.leftShoulder.index) continue;
      final p = point(t);
      if (p != null) canvas.drawCircle(p, 3.5, dot);
    }
  }

  @override
  bool shouldRepaint(_SkeletonPainter old) =>
      old.lm != lm || old.mirror != mirror;
}

class _ApproveResult {
  final int? total;
  final int? correct;
  final String? note;
  const _ApproveResult(this.total, this.correct, this.note);
}

class _ApproveDialog extends StatefulWidget {
  const _ApproveDialog();

  @override
  State<_ApproveDialog> createState() => _ApproveDialogState();
}

class _ApproveDialogState extends State<_ApproveDialog> {
  final _total = TextEditingController();
  final _correct = TextEditingController();
  final _note = TextEditingController();

  @override
  void dispose() {
    _total.dispose();
    _correct.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final digits = [FilteringTextInputFormatter.digitsOnly];
    return AlertDialog(
      title: const Text('Запись подходит'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Видео удалится, точки сохранятся. Укажи, сколько повторов '
            'было на самом деле — это эталон для проверки счётчика.',
          ),
          TextField(
            controller: _total,
            keyboardType: TextInputType.number,
            inputFormatters: digits,
            decoration: const InputDecoration(labelText: 'Всего повторов'),
          ),
          TextField(
            controller: _correct,
            keyboardType: TextInputType.number,
            inputFormatters: digits,
            decoration: const InputDecoration(labelText: 'Из них верных'),
          ),
          TextField(
            controller: _note,
            decoration: const InputDecoration(
                labelText: 'Заметка (паузы, ошибки, темп…)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            _ApproveResult(
              int.tryParse(_total.text),
              int.tryParse(_correct.text),
              _note.text.trim().isEmpty ? null : _note.text.trim(),
            ),
          ),
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
