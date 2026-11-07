import 'dart:math' as math;

import 'package:pose_detection/pose_detection.dart';

const int kLandmarkStride = 4;

double angleDeg(
    double ax, double ay, double bx, double by, double cx, double cy) {
  final v1x = ax - bx, v1y = ay - by;
  final v2x = cx - bx, v2y = cy - by;
  final n1 = math.sqrt(v1x * v1x + v1y * v1y);
  final n2 = math.sqrt(v2x * v2x + v2y * v2y);
  if (n1 == 0 || n2 == 0) return double.nan;
  final cos = ((v1x * v2x + v1y * v2y) / (n1 * n2)).clamp(-1.0, 1.0);
  return math.acos(cos) * 180 / math.pi;
}

class JointAngleSpec {
  final String id;
  final String label;
  final List<PoseLandmarkType> left;
  final List<PoseLandmarkType> right;

  const JointAngleSpec({
    required this.id,
    required this.label,
    required this.left,
    required this.right,
  });

  static const elbow = JointAngleSpec(
    id: 'elbow',
    label: 'Локоть',
    left: [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.leftWrist,
    ],
    right: [
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.rightWrist,
    ],
  );

  static const bodyLine = JointAngleSpec(
    id: 'bodyLine',
    label: 'Линия корпуса',
    left: [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftAnkle,
    ],
    right: [
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightAnkle,
    ],
  );

  static const knee = JointAngleSpec(
    id: 'knee',
    label: 'Колено',
    left: [
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.leftAnkle,
    ],
    right: [
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.rightAnkle,
    ],
  );

  static const hip = JointAngleSpec(
    id: 'hip',
    label: 'Таз',
    left: [
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
    ],
    right: [
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
    ],
  );
}

double? measureAngle(
  List<double> lm,
  JointAngleSpec spec, {
  double minVisibility = 0.5,
}) {
  ({double angle, double vis})? side(List<PoseLandmarkType> t) {
    var visSum = 0.0;
    for (final p in t) {
      final v = lm[p.index * kLandmarkStride + 3];
      if (v < minVisibility) return null;
      visSum += v;
    }
    double x(PoseLandmarkType p) => lm[p.index * kLandmarkStride];
    double y(PoseLandmarkType p) => lm[p.index * kLandmarkStride + 1];
    final a = angleDeg(x(t[0]), y(t[0]), x(t[1]), y(t[1]), x(t[2]), y(t[2]));
    if (a.isNaN) return null;
    return (angle: a, vis: visSum);
  }

  final l = side(spec.left);
  final r = side(spec.right);
  if (l == null) return r?.angle;
  if (r == null) return l.angle;
  return l.vis >= r.vis ? l.angle : r.angle;
}
