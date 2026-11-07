import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pose_detection/pose_detection.dart';

import '../services/pose_geometry.dart';

enum DevExercise { pushUp, squat }

extension DevExerciseExt on DevExercise {
  String get label => switch (this) {
        DevExercise.pushUp => 'Отжимания',
        DevExercise.squat => 'Приседания',
      };

  List<JointAngleSpec> get metrics => switch (this) {
        DevExercise.pushUp => const [
            JointAngleSpec.elbow,
            JointAngleSpec.bodyLine,
          ],
        DevExercise.squat => const [
            JointAngleSpec.knee,
            JointAngleSpec.hip,
          ],
      };
}

enum DevCameraView { side, front, diagonal }

extension DevCameraViewExt on DevCameraView {
  String get label => switch (this) {
        DevCameraView.side => 'Сбоку',
        DevCameraView.front => 'Спереди',
        DevCameraView.diagonal => 'Под 45°',
      };
}

enum DevRecordingStatus { pending, approved }

class LandmarkFrame {
  final int t;
  final List<double>? lm;

  const LandmarkFrame(this.t, this.lm);

  static List<double> fromPose(Pose pose) {
    double r1(double v) => (v * 10).roundToDouble() / 10;
    double r3(double v) => (v * 1000).roundToDouble() / 1000;
    final out = List<double>.filled(
        PoseLandmarkType.values.length * kLandmarkStride, 0);
    for (final l in pose.landmarks) {
      final i = l.type.index * kLandmarkStride;
      out[i] = r1(l.x);
      out[i + 1] = r1(l.y);
      out[i + 2] = r1(l.z);
      out[i + 3] = r3(l.visibility);
    }
    return out;
  }
}

class DevRecording {
  final String id;
  final DevExercise exercise;
  final DevCameraView view;
  final String lens;
  final DateTime createdAt;
  final int imageWidth;
  final int imageHeight;
  final List<LandmarkFrame> frames;
  DevRecordingStatus status;
  String? videoFileName;
  int? totalReps;
  int? correctReps;
  String? note;

  DevRecording({
    required this.id,
    required this.exercise,
    required this.view,
    required this.lens,
    required this.createdAt,
    required this.imageWidth,
    required this.imageHeight,
    required this.frames,
    this.status = DevRecordingStatus.pending,
    this.videoFileName,
    this.totalReps,
    this.correctReps,
    this.note,
  });

  int get durationMs => frames.isEmpty ? 0 : frames.last.t;

  double get detectedRatio => frames.isEmpty
      ? 0
      : frames.where((f) => f.lm != null).length / frames.length;

  double get avgFps =>
      durationMs == 0 ? 0 : frames.length / (durationMs / 1000);

  LandmarkFrame? frameAt(int ms) {
    if (frames.isEmpty || ms < frames.first.t) return null;
    var lo = 0, hi = frames.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (frames[mid].t <= ms) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return frames[lo];
  }

  Map<String, dynamic> toJson() => {
        'version': 1,
        'id': id,
        'exercise': exercise.name,
        'view': view.name,
        'lens': lens,
        'createdAt': createdAt.toIso8601String(),
        'imageWidth': imageWidth,
        'imageHeight': imageHeight,
        'status': status.name,
        'videoFile': videoFileName,
        'totalReps': totalReps,
        'correctReps': correctReps,
        'note': note,
        'frames': [
          for (final f in frames) {'t': f.t, 'lm': f.lm},
        ],
      };

  factory DevRecording.fromJson(Map<String, dynamic> j) => DevRecording(
        id: j['id'] as String,
        exercise: DevExercise.values.byName(j['exercise'] as String),
        view: DevCameraView.values.byName(j['view'] as String),
        lens: j['lens'] as String? ?? 'front',
        createdAt: DateTime.parse(j['createdAt'] as String),
        imageWidth: j['imageWidth'] as int,
        imageHeight: j['imageHeight'] as int,
        status: DevRecordingStatus.values.byName(j['status'] as String),
        videoFileName: j['videoFile'] as String?,
        totalReps: j['totalReps'] as int?,
        correctReps: j['correctReps'] as int?,
        note: j['note'] as String?,
        frames: [
          for (final f in j['frames'] as List)
            LandmarkFrame(
              f['t'] as int,
              (f['lm'] as List?)
                  ?.map((v) => (v as num).toDouble())
                  .toList(growable: false),
            ),
        ],
      );
}

class DevRecordingStore {
  static const _folder = 'pose_dev_recordings';

  static Future<Directory> directory() async {
    Directory? base;
    if (Platform.isAndroid) base = await getExternalStorageDirectory();
    base ??= await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/$_folder');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<List<DevRecording>> loadAll() async {
    final dir = await directory();
    final result = <DevRecording>[];
    await for (final e in dir.list()) {
      if (e is! File || !e.path.endsWith('.json')) continue;
      try {
        final json = jsonDecode(await e.readAsString());
        result.add(DevRecording.fromJson(json as Map<String, dynamic>));
      } catch (_) {
      }
    }
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  static Future<void> save(DevRecording r) async {
    final dir = await directory();
    await File('${dir.path}/${r.id}.json').writeAsString(jsonEncode(r.toJson()));
  }

  static Future<String> importVideo(String id, String sourcePath) async {
    final dir = await directory();
    final ext = sourcePath.contains('.') ? sourcePath.split('.').last : 'mp4';
    final name = '$id.$ext';
    final target = '${dir.path}/$name';
    final source = File(sourcePath);
    try {
      await source.rename(target);
    } on FileSystemException {
      await source.copy(target);
      await source.delete();
    }
    return name;
  }

  static Future<File?> videoFile(DevRecording r) async {
    final name = r.videoFileName;
    if (name == null) return null;
    final f = File('${(await directory()).path}/$name');
    return await f.exists() ? f : null;
  }

  static Future<void> deleteVideo(DevRecording r) async {
    final f = await videoFile(r);
    if (f != null) await f.delete();
    r.videoFileName = null;
  }

  static Future<void> delete(DevRecording r) async {
    await deleteVideo(r);
    final f = File('${(await directory()).path}/${r.id}.json');
    if (await f.exists()) await f.delete();
  }
}
