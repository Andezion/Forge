import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'dev_record_screen.dart';
import 'dev_recording.dart';
import 'dev_review_screen.dart';

class DevTestScreen extends StatefulWidget {
  const DevTestScreen({super.key});

  @override
  State<DevTestScreen> createState() => _DevTestScreenState();
}

class _DevTestScreenState extends State<DevTestScreen> {
  List<DevRecording>? _items;
  String? _dirPath;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final items = await DevRecordingStore.loadAll();
    final dir = await DevRecordingStore.directory();
    if (!mounted) return;
    setState(() {
      _items = items;
      _dirPath = dir.path;
    });
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
    await _reload();
  }

  Future<void> _newRecording() async {
    final choice = await showModalBottomSheet<_NewRecordingChoice>(
      context: context,
      builder: (_) => const _NewRecordingSheet(),
    );
    if (choice == null) return;
    await _open(DevRecordScreen(
      exercise: choice.exercise,
      view: choice.view,
      countdownSeconds: choice.countdown,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      appBar: AppBar(title: const Text('Тест (калибровка)')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newRecording,
        icon: const Icon(Icons.videocam),
        label: const Text('Новая запись'),
      ),
      body: items == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                children: [
                  _buildSummary(items),
                  const SizedBox(height: 12),
                  if (items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Записей пока нет. Сними упражнение: камера '
                        'неподвижно, всё тело в кадре, в верхней и нижней '
                        'точке делай паузу ~1 c.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  for (final r in items) _buildTile(r),
                ],
              ),
            ),
    );
  }

  Widget _buildSummary(List<DevRecording> items) {
    final approved =
        items.where((r) => r.status == DevRecordingStatus.approved);
    final pending = items.length - approved.length;
    final rows = <String>[];
    for (final e in DevExercise.values) {
      for (final v in DevCameraView.values) {
        final group = approved.where((r) => r.exercise == e && r.view == v);
        if (group.isEmpty) continue;
        final reps = group.fold<int>(0, (s, r) => s + (r.correctReps ?? 0));
        rows.add('${e.label} · ${v.label}: ${group.length} зап., '
            '$reps верных повторов');
      }
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Одобрено: ${approved.length} · ждут просмотра: $pending',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (rows.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(rows.join('\n'), style: const TextStyle(height: 1.4)),
            ],
            if (_dirPath != null) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _dirPath!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Путь скопирован')),
                  );
                },
                child: Text(
                  'Папка: $_dirPath',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTile(DevRecording r) {
    final pending = r.status == DevRecordingStatus.pending;
    final date = DateFormat('dd.MM HH:mm').format(r.createdAt);
    final secs = (r.durationMs / 1000).toStringAsFixed(0);
    final reps = pending
        ? 'нужно просмотреть'
        : 'повторов ${r.totalReps ?? '?'}, верных ${r.correctReps ?? '?'}';
    return Card(
      child: ListTile(
        leading: Icon(
          pending ? Icons.hourglass_top : Icons.check_circle,
          color: pending ? Colors.orange : Colors.green,
        ),
        title: Text('${r.exercise.label} · ${r.view.label}'),
        subtitle: Text('$date · $secs c · $reps'
            '${(r.note ?? '').isEmpty ? '' : '\n${r.note}'}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _open(DevReviewScreen(recording: r)),
      ),
    );
  }
}

class _NewRecordingChoice {
  final DevExercise exercise;
  final DevCameraView view;
  final int countdown;
  const _NewRecordingChoice(this.exercise, this.view, this.countdown);
}

class _NewRecordingSheet extends StatefulWidget {
  const _NewRecordingSheet();

  @override
  State<_NewRecordingSheet> createState() => _NewRecordingSheetState();
}

class _NewRecordingSheetState extends State<_NewRecordingSheet> {
  DevExercise _exercise = DevExercise.pushUp;
  DevCameraView _view = DevCameraView.side;
  int _countdown = 5;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Упражнение'),
            const SizedBox(height: 6),
            Wrap(spacing: 8, children: [
              for (final e in DevExercise.values)
                ChoiceChip(
                  label: Text(e.label),
                  selected: _exercise == e,
                  onSelected: (_) => setState(() => _exercise = e),
                ),
            ]),
            const SizedBox(height: 14),
            const Text('Ракурс камеры'),
            const SizedBox(height: 6),
            Wrap(spacing: 8, children: [
              for (final v in DevCameraView.values)
                ChoiceChip(
                  label: Text(v.label),
                  selected: _view == v,
                  onSelected: (_) => setState(() => _view = v),
                ),
            ]),
            const SizedBox(height: 14),
            const Text('Отсчёт перед записью'),
            const SizedBox(height: 6),
            Wrap(spacing: 8, children: [
              for (final s in const [3, 5, 10, 15])
                ChoiceChip(
                  label: Text('$s c'),
                  selected: _countdown == s,
                  onSelected: (_) => setState(() => _countdown = s),
                ),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.videocam),
                label: const Text('К камере'),
                onPressed: () => Navigator.pop(
                  context,
                  _NewRecordingChoice(_exercise, _view, _countdown),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
