import '../../models/exercise.dart';

class BodyMapRegion {
  final String name;
  final MuscleGroup? group;
  final String path;
  final bool mirrored;

  const BodyMapRegion(this.name, this.group, this.path, {this.mirrored = true});
}

class BodyMapData {
  static const double width = 200;
  static const double height = 460;

  static const String silhouette =
      'M100 6 C89 6 83 14 83 28 C83 34 83 39 84 44 '
      'C81 45 81 50 84 52 C85 57 88 61 90 63 L90 70 '
      'C84 76 70 82 56 86 C44 89 33 96 30 110 '
      'C28 122 29 134 30 142 C29 156 30 168 31 178 '
      'C27 190 25 202 27 214 C28 226 31 236 33 246 '
      'C29 256 28 270 31 282 C33 290 40 292 43 285 '
      'C45 276 46 258 45 248 C47 236 50 220 52 206 '
      'C53 196 52 186 51 180 C54 166 56 150 57 136 '
      'C57.5 132 58 130 59 128 C61 150 64 175 68 198 '
      'C67 210 64 220 63 232 C60 250 59 275 62 300 '
      'C64 315 67 325 69 336 C66 348 64 360 65 372 '
      'C66 388 72 408 76 424 C73 434 68 444 72 450 '
      'C78 455 88 454 92 448 C93 440 91 432 90 424 '
      'C91 410 92 395 93 380 C95 365 95 350 92 338 '
      'C94 320 97 290 98 270 L100 258 Z';

  static final String silhouetteOutline =
      silhouette.substring(0, silhouette.lastIndexOf(' Z'));

  static const List<String> frontDetails = [
    // Collarbone
    'M97 87 C88 86 74 87 62 89',
    // Kneecap
    'M76 340 C79 334 86 334 89 340 C87 347 79 348 76 340 Z',
    // Fingers
    'M36 270 C36 276 37 282 38 287',
    'M40 268 C40 274 41 280 41 286',
  ];

  static const List<String> backDetails = [
    // Spine
    'M100 58 L100 258',
    // Back of the knee
    'M74 340 C80 344 87 344 92 340',
    // Fingers
    'M36 270 C36 276 37 282 38 287',
    'M40 268 C40 274 41 280 41 286',
  ];

  static const List<BodyMapRegion> front = [
    // Neck
    BodyMapRegion('Sternocleidomastoid', null,
        'M86.5 57 C89 66 92.5 76 96 86 L98.5 86 C96 75 93 65 89.5 56 Z'),
    BodyMapRegion('Trapezius', MuscleGroup.back,
        'M90 69 C84 76 71 81 58 86 C66 87 76 86 85 84 C88 80 90 75 90 69 Z'),

    // Shoulders
    BodyMapRegion('Deltoid (middle head)', MuscleGroup.shoulders,
        'M49 89 C40 91 33 98 31 108 C29 122 30 136 34 146 '
        'C37 149 40 151 43 152 C41 130 43 106 49 89 Z'),
    BodyMapRegion('Deltoid (anterior head)', MuscleGroup.shoulders,
        'M63 89 C58 88 53 88 50 89 C44 106 42 128 44 152 '
        'C46 140 50 124 55 113 C58 105 61 97 63 89 Z'),

    // Chest
    BodyMapRegion('Pectoralis major (clavicular head)', MuscleGroup.chest,
        'M98 90 C88 89 75 90 64 91 C62 98 59 106 56 112 '
        'C66 107 82 104 98 104 Z'),
    BodyMapRegion('Pectoralis major (sternal head)', MuscleGroup.chest,
        'M98 106.5 C82 106.5 66 109.5 56.4 114.6 C56 119 57 124 59 128 '
        'C64 136 74 142 84 143 C90 143 95 142 98 140 Z'),

    // Arms
    BodyMapRegion('Brachialis', MuscleGroup.biceps,
        'M33 148 C37 150 40 152 43 153 C41 161 39 169 38 176 '
        'C36 178 33 178 31 177 C30 166 30 156 31 148 Z'),
    BodyMapRegion('Biceps brachii (long head)', MuscleGroup.biceps,
        'M52 120 C48 130 46 141 44 153 C42 161 40 169 40 176 '
        'C42 179 44 180 46 179 C47 164 49 142 52 120 Z'),
    BodyMapRegion('Biceps brachii (short head)', MuscleGroup.biceps,
        'M53 118 C50 142 48 164 47.5 179 C49 180 50 180 51 178 '
        'C54 164 56 148 57 136 C57.5 132 58 129 58.5 127 '
        'C57 122 56 118 55 114 C54 115 53.5 116 53 118 Z'),
    BodyMapRegion('Brachioradialis', MuscleGroup.forearms,
        'M31.5 180 C27 190 25 202 27 214 C28.5 224 31 232 34 238 '
        'C35 224 36 208 37.5 192 C36.5 186 34.5 182 31.5 180 Z'),
    BodyMapRegion('Pronator teres', MuscleGroup.forearms,
        'M39 182 C43 181.5 47 181 50.5 181 C51 186 50 190 48 193.5 '
        'C45 198 42 203 38.5 207 C38.5 200 38.5 192 39 182 Z'),
    BodyMapRegion('Flexor carpi radialis', MuscleGroup.forearms,
        'M38.5 209.5 C42 205 45 200 48 195.5 C47 210 44.5 226 42.5 239 '
        'L36.5 239 C36.5 230 37 220 38.5 209.5 Z'),
    BodyMapRegion('Flexor carpi ulnaris', MuscleGroup.forearms,
        'M49.5 195 C51 191 51.8 186 52 182 C52.8 192 52.8 200 51.8 208 '
        'C50 222 47 234 45.2 245 L43.8 239 C45.5 226 48 210 49.5 195 Z'),
    BodyMapRegion('Wrist flexor tendons', MuscleGroup.wrists,
        'M35 241 L44 241 C44.4 243.5 44.8 246 45 248 '
        'L33.2 247 C34 245 34.6 243 35 241 Z'),

    // Abdomen
    BodyMapRegion('External oblique', MuscleGroup.core,
        'M66 134 C72 136 78 142 82 150 C80 172 80 196 82 214 '
        'C83 224 85 232 87 238 C78 234 70 228 64.5 222 '
        'C66 212 68 204 68 198 C66 180 64 160 62 140 '
        'C63 137 64.5 135 66 134 Z'),
    BodyMapRegion('Serratus anterior', MuscleGroup.core,
        'M61.5 132 C65 131.5 69 132.5 72 134.5 C70 137 66 138 62 138.5 Z'),
    BodyMapRegion('Serratus anterior', MuscleGroup.core,
        'M62 141 C66 140.5 70 141.5 73 143.5 C71 146 67 147 62.6 147.5 Z'),
    BodyMapRegion('Serratus anterior', MuscleGroup.core,
        'M62.8 150 C67 149.5 71 150.5 74 152.5 C72 155 68 156 63.4 156.5 Z'),
    BodyMapRegion('Serratus anterior', MuscleGroup.core,
        'M63.6 159 C67.5 158.5 71.5 159.5 74.5 161.5 C72.5 164 68.5 165 64.2 165.5 Z'),
    BodyMapRegion('Rectus abdominis', MuscleGroup.core,
        'M98.5 146 C93 146 87 147 83.2 150 C83 157 83 164 83.5 171 '
        'C88 172 93 172.5 98.5 172.5 Z'),
    BodyMapRegion('Rectus abdominis', MuscleGroup.core,
        'M98.5 175 C93 175 88 174.5 83.6 174 C83.6 181 83.6 188 84 195 '
        'C88 196 93 196.5 98.5 196.5 Z'),
    BodyMapRegion('Rectus abdominis', MuscleGroup.core,
        'M98.5 199 C93 199 88 198.5 84.2 198 C84.2 205 84.6 211 85.2 217 '
        'C89 218 94 218.5 98.5 218.5 Z'),
    BodyMapRegion('Rectus abdominis', MuscleGroup.core,
        'M98.5 221 C94 221 89 220.5 85.6 220 C86 231 89 241 93 249 '
        'C95 252 97 254 98.5 255 Z'),

    // Thigh
    BodyMapRegion('Tensor fasciae latae', MuscleGroup.glutes,
        'M64.5 226 C61.5 236 60.5 248 61 260 C64.5 255 68 247 70.5 239 '
        'C69 234 67 229.5 64.5 226 Z'),
    BodyMapRegion('Iliopsoas', MuscleGroup.legs,
        'M70.5 236 C74.5 238.5 78.5 241.5 82 245.5 C80 249.5 78 253.5 76.4 258 '
        'C74.2 251 72.2 243.5 70.5 236 Z'),
    BodyMapRegion('Pectineus', MuscleGroup.legs,
        'M75 241 C81 246 88 251 95 257 C91 261 87 264 83 266 '
        'C80 260 77.5 252 75 247 Z'),
    BodyMapRegion('Adductor longus', MuscleGroup.legs,
        'M78 258 C80.5 263 83 267 85 269.5 C88 266.5 91 263.5 94.5 261 '
        'C94 276 92 290 90 302 C86 287 82 272 78 258 Z'),
    BodyMapRegion('Gracilis', MuscleGroup.legs,
        'M96.5 262 C97.8 268 98 274 97.5 284 C96.8 296 95.6 307 94.4 316 '
        'L91.5 307 C93.4 294 94.6 280 95 266 Z'),
    BodyMapRegion('Vastus lateralis', MuscleGroup.legs,
        'M62.5 262 C60.5 274 60.5 290 62 304 C63.6 316 66.5 326 69.5 335 '
        'C72.5 335 75.5 333 78 329 C74 324 71 318 69 310 '
        'C66 294 65.5 274 67 256 C65 257.5 63.6 259.5 62.5 262 Z'),
    BodyMapRegion('Rectus femoris', MuscleGroup.legs,
        'M69 250 C66.5 268 66.5 292 70 312 C72 320 75 325 79 327.5 '
        'C82.6 318 84 306 84 294 C80 280 75 264 69 250 Z'),
    BodyMapRegion('Vastus medialis', MuscleGroup.legs,
        'M85.5 298 C88.5 306 91 314 92.4 322 C92.4 330 90 336 85 338 '
        'C81 336 79 332 79.5 328.5 C83 320 85 310 85.5 298 Z'),
    BodyMapRegion('Sartorius', MuscleGroup.legs,
        'M67.5 231 C69 237 71 242 73 246.5 C79 268 86 292 94.6 314 '
        'L92.6 322 C84.5 299 76.5 275 70 254.5 C68 246 67 238 67.5 231 Z'),

    // Lower leg
    BodyMapRegion('Peroneus longus', MuscleGroup.calves,
        'M68.5 345 C65.5 358 64.5 372 66 386 C68 399 71 410 74 420 '
        'L76.5 418 C74.5 406 73 394 72 381 C71.4 368 71.6 356 72.3 345 Z'),
    BodyMapRegion('Extensor digitorum longus', MuscleGroup.calves,
        'M73.4 347 C72.8 360 73 374 74.2 388 C75 398 76.4 408 78 416 '
        'L79.6 414 C78.4 402 77.4 390 76.8 378 C76.4 366 76.2 356 75.6 348 Z'),
    BodyMapRegion('Tibialis anterior', MuscleGroup.calves,
        'M76.8 346 C77.4 358 77.8 370 78.4 382 C79 394 79.8 404 80.8 412 '
        'L82.4 410 C82.6 396 82.6 382 82.2 368 C81.8 358 80.8 350 79.4 345.5 Z'),
    BodyMapRegion('Gastrocnemius (medial head)', MuscleGroup.calves,
        'M87.8 342 C92.6 350 94.6 362 94 374 C93.2 384 91 392 88 398 '
        'C86 390 85 378 85 366 C85 356 86 348 87.8 342 Z'),
    BodyMapRegion('Soleus', MuscleGroup.calves,
        'M86.6 402 C89.6 396 91.6 390 92.6 384 C92 396 91.2 406 90.4 418 '
        'L88.2 418 C87.2 412 86.6 407 86.6 402 Z'),
  ];

  static const List<BodyMapRegion> back = [
    // Upper back
    BodyMapRegion('Trapezius', MuscleGroup.back,
        'M100 58 C96 61 92.5 65 90 69 C84 76 71 81 58 86 '
        'C62 92 70 100 78 108 C84 124 92 146 100 170 Z'),
    BodyMapRegion('Infraspinatus', MuscleGroup.shoulders,
        'M77 111 C71 107 64 105 59.5 110 C58.5 118 59 126 62.5 132 '
        'C68.5 134 74 132.5 80.5 128.5 C80 122 78.8 116 77 111 Z'),
    BodyMapRegion('Teres minor', MuscleGroup.shoulders,
        'M58 113 C55.5 119 55 125 56 130.5 C57.5 132 59 133 60.8 133.4 '
        'C58.6 126 57.8 119 58 113 Z'),
    BodyMapRegion('Teres major', MuscleGroup.back,
        'M62 135 C68 137 74 135.5 80.6 131.5 C80.6 137 78.5 141 74.5 143.5 '
        'C68.5 144.5 62.5 142.5 59 138.5 C59.8 136.8 60.8 135.6 62 135 Z'),
    BodyMapRegion('Latissimus dorsi', MuscleGroup.back,
        'M60 140 C66 144.5 73 146.5 80.5 144 C82 141 82 137 81.5 133 '
        'C88 150 93 166 98.5 184 L98.5 194 C92 199 86 203.5 80 207.5 '
        'C76 205.5 72 203.5 69 201.5 C68 197 67 190 66 182 '
        'C64 166 62 152 60 140 Z'),

    // Shoulders
    BodyMapRegion('Deltoid (middle head)', MuscleGroup.shoulders,
        'M50 88.5 C40 91 33 98 31 108 C29 122 30 136 34 146 '
        'C37 149 40 151 42.5 151.5 C40 130 42 106 50 88.5 Z'),
    BodyMapRegion('Deltoid (posterior head)', MuscleGroup.shoulders,
        'M58.5 87 C56 87 53.5 87.5 51.5 88.2 C43.5 106 41.5 130 44 151.8 '
        'C45 152 45.8 151.6 46.4 150.5 C48 138 52 124 56.5 114 '
        'C60 108 63.5 104 67 101 C63.5 96 61 91.5 58.5 87 Z'),

    // Arms
    BodyMapRegion('Triceps brachii (lateral head)', MuscleGroup.triceps,
        'M43 152.5 C39 151.5 36 149.5 33 147.5 C31 158 31 168 32.5 176 '
        'C36 172 40 168 44 164.5 C44.6 160 45 156.5 43 152.5 Z'),
    BodyMapRegion('Triceps brachii (long head)', MuscleGroup.triceps,
        'M47 151 C50.5 141 54 132 58.4 127.5 C57.4 142 55.4 160 52.4 176 '
        'C50.6 177.8 48.6 178 46.6 176.5 C46 168 45.8 159 47 151 Z'),
    BodyMapRegion('Triceps brachii (medial head)', MuscleGroup.triceps,
        'M33 178.5 C36.5 173.5 40.5 169.5 45 166 C45.6 170 46 174 46 178.5 '
        'C42 181.5 37 181.5 33 178.5 Z'),
    BodyMapRegion('Extensor carpi radialis', MuscleGroup.forearms,
        'M31.5 180.5 C27 190 25 202 27 214 C28.5 224 31 232 33.6 238 '
        'C34.6 224 35.6 208 36.6 194 C35.6 188 33.8 183 31.5 180.5 Z'),
    BodyMapRegion('Extensor digitorum', MuscleGroup.forearms,
        'M38.2 185.5 C37.4 203 36.6 221 36.4 239 L40.2 239 '
        'C41.2 222 43 205 45.2 190 C43.2 186.5 40.6 185 38.2 185.5 Z'),
    BodyMapRegion('Extensor carpi ulnaris', MuscleGroup.forearms,
        'M46.6 190.5 C44.4 206 42.6 222 41.6 239 L43.6 239 '
        'C46 223 48.6 207 50.2 194 C49.2 192 48 191 46.6 190.5 Z'),
    BodyMapRegion('Flexor carpi ulnaris', MuscleGroup.forearms,
        'M51.2 182 C52.4 190 52.6 199 51.8 208 C50.2 222 47.4 234 45.2 245 '
        'L44.4 240 C46.8 226 49.6 210 51 196 C51.4 191 51.4 186 51.2 182 Z'),
    BodyMapRegion('Wrist extensor tendons', MuscleGroup.wrists,
        'M35 241 L44 241 C44.4 243.5 44.8 246 45 248 '
        'L33.2 247 C34 245 34.6 243 35 241 Z'),

    // Lower back
    BodyMapRegion('Erector spinae', MuscleGroup.core,
        'M98.5 197 C94.5 200 91 205 89.6 212 C88.8 218 89.6 224 91.6 229 '
        'L98.5 230.5 Z'),
    BodyMapRegion('External oblique', MuscleGroup.core,
        'M69.2 203.5 C72.5 205.5 76 207.5 79.5 209.5 C77.5 215 74 220.5 70 225.5 '
        'C67.8 224.5 66 223.2 64.4 221.8 C66.4 215.5 68 209.5 69.2 203.5 Z'),

    // Hips
    BodyMapRegion('Gluteus medius', MuscleGroup.glutes,
        'M64.6 224.5 C70.5 227 78 223 86.5 222.5 C88.5 228 86.5 234 82.5 238.5 '
        'C76 241 68.5 245 61.4 249 C61.6 240.5 62.8 232 64.6 224.5 Z'),
    BodyMapRegion('Gluteus maximus', MuscleGroup.glutes,
        'M98.5 232 C92 230.5 86.5 234.5 83 240.5 C75 244.5 67 250.5 62.2 258 '
        'C61.2 272 64 282 70 290 C80 292.5 90 291 98.5 285 Z'),

    // Thigh
    BodyMapRegion('Iliotibial band', MuscleGroup.legs,
        'M61.6 264 C60.6 280 61 298 63.6 314 C65.4 324 67.6 331 69.2 336 '
        'L72.2 334.5 C70.2 320 67.6 302 66.4 286 C65.8 278 64.8 270 63.4 263 Z'),
    BodyMapRegion('Biceps femoris', MuscleGroup.legs,
        'M67.8 292.5 C68.6 306 70.4 320 74 330 C75.8 334 77.8 336.5 80.2 338 '
        'C82 326 82.2 312 81.2 296.5 C76.6 296.2 72 294.8 67.8 292.5 Z'),
    BodyMapRegion('Semitendinosus', MuscleGroup.legs,
        'M82.6 296.5 C83.6 310 84.4 324 84.4 338.5 C86 340.2 87.6 340.4 89.2 339 '
        'C89.6 324 89.8 309 89.8 294.5 C87.4 295.6 85 296.3 82.6 296.5 Z'),
    BodyMapRegion('Semimembranosus', MuscleGroup.legs,
        'M91 293.5 C91 309 91 324 90.8 337 C92.2 333 93.4 324 93.8 314 '
        'C94.2 306 94.2 298 94 291.5 C93 292.3 92 293 91 293.5 Z'),
    BodyMapRegion('Adductor magnus', MuscleGroup.legs,
        'M95.6 287.5 C96.6 293 97.2 299 96.8 305 C96.2 300 95.6 296 94.8 292 Z'),
    BodyMapRegion('Gracilis', MuscleGroup.legs,
        'M97.8 291 C97.6 305 96.6 319 94.2 334 L92.6 334.6 '
        'C94.6 320 95.6 306 95.8 293 Z'),

    // Lower leg
    BodyMapRegion('Gastrocnemius (lateral head)', MuscleGroup.calves,
        'M70.4 342.5 C66.4 352 65.4 364 67.2 376 C69 386 73 394 78 398.5 '
        'C80.2 388 81 372 81 356 C79 348.5 75.2 344.4 70.4 342.5 Z'),
    BodyMapRegion('Gastrocnemius (medial head)', MuscleGroup.calves,
        'M83.2 344 C82.2 358 82.2 374 83.2 392 C86 398.5 90 396.5 92.2 388.5 '
        'C94.2 376 94.8 360 92.2 348 C89.4 344.2 86.2 343.2 83.2 344 Z'),
    BodyMapRegion('Peroneus brevis', MuscleGroup.calves,
        'M66.4 380 C67.6 392 70.4 404 73.8 415 L76 413.4 '
        'C72.6 404 69.8 393 68.2 383 Z'),
    BodyMapRegion('Soleus', MuscleGroup.calves,
        'M69.6 390 C71.8 397 75 402.5 79 405 C81 401 82 398 82.6 396 '
        'C84 400.5 87.6 402 91.4 398.5 C91.8 403 91.4 408 90.6 412 '
        'C86.6 410 82 410.5 78.2 412 C74.8 405.5 71.6 398 69.6 390 Z'),
    BodyMapRegion('Flexor hallucis longus', MuscleGroup.calves,
        'M79 414 C82.4 412.4 86.4 412 90.2 414 C89.8 418 89.6 421 89.6 424 '
        'L80.6 424 C80.2 420.5 79.6 417 79 414 Z'),
  ];

  static final Set<MuscleGroup> drawnGroups = {
    for (final region in [...front, ...back])
      if (region.group != null) region.group!,
  };
}
