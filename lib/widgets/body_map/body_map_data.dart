import '../../models/exercise.dart';

class BodyMapRegion {
  final MuscleGroup group;
  final String path;
  final bool mirrored;

  const BodyMapRegion(this.group, this.path, {this.mirrored = true});
}

class BodyMapData {
  static const double width = 200;
  static const double height = 460;

  static const String silhouette =
      'M100 8 C88 8 80 18 80 34 C80 48 84 58 89 64 L89 78 '
      'C80 84 64 87 54 91 C43 95 37 104 36 118 '
      'C34 136 34 156 33 172 C30 190 28 212 30 236 '
      'C27 250 27 264 31 276 C34 284 41 285 44 277 '
      'C46 268 46 252 45 240 C47 222 52 200 54 180 '
      'C56 160 58 142 60 128 C63 150 67 172 70 190 '
      'C67 205 62 218 62 234 C61 264 63 300 69 330 '
      'C67 345 65 360 67 374 C69 394 75 410 77 424 '
      'C73 434 69 444 75 450 C83 453 90 451 92 445 '
      'C93 437 91 430 90 424 C92 400 95 374 93 350 '
      'C94 334 97 300 98 262 L100 248 Z';

  /// [silhouette] without the closing segment along the centre line
  static final String silhouetteOutline =
      silhouette.substring(0, silhouette.lastIndexOf(' Z'));

  /// Decorative outlines that are not tied to a muscle group
  static const List<String> frontDetails = [
    // Collarbone.
    'M96 92 C86 88 72 89 58 93',
    // Abdominal tendinous lines
    'M84 172 C89 174 94 174 98 173',
    'M84 196 C89 198 94 198 98 197',
    'M85 218 C89 220 94 220 98 219',
    // Kneecap
    'M76 336 C80 330 88 330 91 337 C89 344 80 345 76 336 Z',
  ];

  static const List<String> backDetails = [
    // Spine
    'M100 80 L100 248',
    // Back of the knee
    'M74 340 C80 344 88 344 93 340',
  ];

  static const List<BodyMapRegion> front = [
    // Trapezius visible above the collarbone
    BodyMapRegion(MuscleGroup.back,
        'M89 74 C82 82 68 86 56 91 C68 92 82 90 94 86 C92 82 90 78 89 74 Z'),
    // Front deltoid
    BodyMapRegion(MuscleGroup.shoulders,
        'M57 93 C45 96 38 105 37 120 C39 130 43 138 47 142 '
        'C51 130 55 116 61 104 C61 99 60 95 57 93 Z'),
    // Pectoralis major
    BodyMapRegion(MuscleGroup.chest,
        'M98 95 C86 92 72 93 62 100 C58 110 58 122 61 132 '
        'C72 142 88 145 98 141 Z'),
    // Biceps
    BodyMapRegion(MuscleGroup.biceps,
        'M47 145 C41 152 39 162 41 172 C46 178 53 177 56 170 '
        'C58 158 59 144 59 132 C54 134 50 139 47 145 Z'),
    // Forearm
    BodyMapRegion(MuscleGroup.forearms,
        'M35 182 C32 198 31 214 33 230 L44 230 '
        'C46 214 50 198 53 182 C47 178 40 178 35 182 Z'),
    // Wrist band
    BodyMapRegion(MuscleGroup.wrists,
        'M33 232 L44 232 C44 236 45 239 45 242 L31 242 C32 239 33 235 33 232 Z'),
    // Rectus abdominis
    BodyMapRegion(MuscleGroup.core,
        'M98 146 C91 146 86 148 83 152 C81 176 81 202 85 226 '
        'C90 236 95 241 98 243 Z'),
    // External oblique
    BodyMapRegion(MuscleGroup.core,
        'M64 140 C70 158 72 182 70 196 C73 208 77 218 82 226 '
        'C79 202 79 176 81 152 C76 146 70 142 64 140 Z'),
    // Quadriceps
    BodyMapRegion(MuscleGroup.legs,
        'M66 242 C64 270 66 300 72 326 C78 331 86 331 91 326 '
        'C92 308 91 288 88 270 C84 258 76 248 66 242 Z'),
    // Adductors
    BodyMapRegion(MuscleGroup.legs,
        'M88 256 C92 262 94 274 93 290 C94 298 95 304 95 310 '
        'C97 292 98 274 98 258 C95 254 91 254 88 256 Z'),
    // Tibialis anterior
    BodyMapRegion(MuscleGroup.calves,
        'M70 352 C68 372 71 392 76 412 L81 412 '
        'C81 392 80 370 79 351 C76 348 72 349 70 352 Z'),
    // Inner gastrocnemius
    BodyMapRegion(MuscleGroup.calves,
        'M85 350 C92 362 94 382 90 402 C87 398 85 382 84 366 '
        'C84 360 84 355 85 350 Z'),
  ];

  static const List<BodyMapRegion> back = [
    // Trapezius
    BodyMapRegion(MuscleGroup.back,
        'M100 68 C97 78 92 84 58 91 C68 98 80 108 88 128 '
        'C93 146 97 158 100 166 Z'),
    // Rear deltoid
    BodyMapRegion(MuscleGroup.shoulders,
        'M55 93 C45 96 38 105 37 120 C41 128 47 131 52 127 '
        'C55 116 59 105 64 98 C61 95 58 93 55 93 Z'),
    // Latissimus dorsi
    BodyMapRegion(MuscleGroup.back,
        'M64 108 C60 126 62 152 70 190 C76 196 82 198 86 196 '
        'C86 176 88 160 92 150 C88 132 78 116 64 108 Z'),
    // Erector spinae
    BodyMapRegion(MuscleGroup.core,
        'M98 160 C93 166 89 178 88 196 C88 210 92 220 98 226 Z'),
    // Triceps
    BodyMapRegion(MuscleGroup.triceps,
        'M38 124 C35 140 35 158 39 172 C45 177 52 176 55 169 '
        'C57 152 58 138 55 128 C49 131 42 130 38 124 Z'),
    // Forearm
    BodyMapRegion(MuscleGroup.forearms,
        'M35 182 C32 198 31 214 33 230 L44 230 '
        'C46 214 50 198 53 182 C47 178 40 178 35 182 Z'),
    // Wrist band
    BodyMapRegion(MuscleGroup.wrists,
        'M33 232 L44 232 C44 236 45 239 45 242 L31 242 C32 239 33 235 33 232 Z'),
    // Gluteus
    BodyMapRegion(MuscleGroup.glutes,
        'M98 226 C88 222 74 224 66 234 C62 248 64 262 70 272 '
        'C82 278 92 277 99 272 Z'),
    // Hamstrings
    BodyMapRegion(MuscleGroup.legs,
        'M69 282 C67 302 70 320 74 332 C81 337 89 337 93 331 '
        'C96 312 97 294 97 280 C88 284 77 285 69 282 Z'),
    // Gastrocnemius
    BodyMapRegion(MuscleGroup.calves,
        'M70 350 C66 366 68 386 75 400 C81 403 87 401 91 396 '
        'C95 380 94 362 90 349 C84 345 76 345 70 350 Z'),
  ];

  /// Muscle groups that have a shape on the map (cardio has none)
  static final Set<MuscleGroup> drawnGroups = {
    for (final region in [...front, ...back]) region.group,
  };
}
