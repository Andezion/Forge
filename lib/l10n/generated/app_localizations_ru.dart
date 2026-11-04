import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Forge';

  @override
  String get profile => 'Профиль';

  @override
  String get home => 'Главная';

  @override
  String get workout => 'Тренировка';

  @override
  String get friends => 'Друзья';

  @override
  String get calendar => 'Календарь';

  @override
  String get progress => 'Прогресс';

  @override
  String get workouts => 'Тренировки';

  @override
  String get bodyWeight => 'Вес тела';

  @override
  String get wellness => 'Самочувствие';

  @override
  String get oneRepMax => 'Калькулятор 1ПМ';

  @override
  String get logout => 'Выйти';

  @override
  String get done => 'Готово';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Изменить';

  @override
  String get add => 'Добавить';

  @override
  String get skip => 'Пропустить';

  @override
  String get next => 'Далее';

  @override
  String get back => 'Назад';

  @override
  String get settings => 'Настройки';

  @override
  String get customization => 'Кастомизация';

  @override
  String get achievements => 'Достижения';

  @override
  String get progressCharts => 'Графики прогресса';

  @override
  String get aboutMe => 'Обо мне';

  @override
  String get easy => 'Легко';

  @override
  String get medium => 'Средне';

  @override
  String get hard => 'Тяжело';

  @override
  String get profileInformation => 'Информация профиля';

  @override
  String get nickname => 'Никнейм';

  @override
  String get region => 'Регион';

  @override
  String get language => 'Язык';

  @override
  String get unitsOfMeasurement => 'Единицы измерения';

  @override
  String get weight => 'Вес';

  @override
  String get distance => 'Расстояние';

  @override
  String get privacySettings => 'Настройки приватности';

  @override
  String get publicProfile => 'Публичный профиль';

  @override
  String get publicProfileDesc =>
      'Разрешить другим видеть информацию вашего профиля';

  @override
  String get showWorkoutHistory => 'Показывать историю тренировок';

  @override
  String get showWorkoutHistoryDesc =>
      'Показывать вашу историю тренировок друзьям';

  @override
  String get showPersonalRecords => 'Показывать личные рекорды';

  @override
  String get showPersonalRecordsDesc =>
      'Позволить другим видеть ваши личные рекорды';

  @override
  String get allowFriendRequests => 'Разрешить запросы в друзья';

  @override
  String get allowFriendRequestsDesc =>
      'Разрешить другим отправлять вам запросы в друзья';

  @override
  String get saveProfileInfo => 'Сохранить информацию профиля';

  @override
  String get profileInfoSaved => 'Информация профиля сохранена!';

  @override
  String get themeColorUpdated => 'Цвет темы обновлён!';

  @override
  String get darkThemeEnabled => 'Тёмная тема включена';

  @override
  String get lightThemeEnabled => 'Светлая тема включена';

  @override
  String get enterNickname => 'Введите ваш никнейм';

  @override
  String get enterRegion => 'например, Россия, Европа, Азия';

  @override
  String get kilograms => 'Килограммы (кг)';

  @override
  String get pounds => 'Фунты (lb)';

  @override
  String get meters => 'Метры (м)';

  @override
  String get feet => 'Футы (ft)';

  @override
  String get english => 'English';

  @override
  String get russian => 'Русский';

  @override
  String workoutSaved(String name) {
    return 'Тренировка сохранена: $name';
  }

  @override
  String get deleteWorkout => 'Удалить тренировку';

  @override
  String deleteWorkoutConfirm(String name) {
    return 'Вы уверены, что хотите удалить \"$name\"?';
  }

  @override
  String get workoutCompleted => 'Тренировка завершена!';

  @override
  String get createYourWorkout => 'Создайте свою тренировку';

  @override
  String get customizeTrainingProgram => 'Настройте свою программу тренировок';

  @override
  String get createNewWorkout => 'Создать новую тренировку';

  @override
  String get myWorkouts => 'Мои тренировки';

  @override
  String get noWorkoutsYet => 'Пока нет тренировок. Создайте свою первую!';

  @override
  String get exitWorkout => 'Выйти из тренировки?';

  @override
  String get progressWillBeLost => 'Ваш прогресс будет потерян.';

  @override
  String get exit => 'Выйти';

  @override
  String setComplete(int number) {
    return 'Подход $number завершён';
  }

  @override
  String targetReps(int reps) {
    String _temp0 = intl.Intl.pluralLogic(
      reps,
      locale: localeName,
      other: 'Цель: $reps повторения',
      many: 'Цель: $reps повторений',
      few: 'Цель: $reps повторения',
      one: 'Цель: $reps повторение',
    );
    return '$_temp0';
  }

  @override
  String get howWasExercise => 'Как прошло это упражнение?';

  @override
  String get workoutComplete => 'Тренировка завершена!';

  @override
  String duration(String time) {
    return 'Продолжительность: $time';
  }

  @override
  String completedExercises(int count) {
    return 'Выполнено: $count';
  }

  @override
  String get skippedExercises => 'Пропущенные упражнения:';

  @override
  String get noRemainingExercises => 'Нет оставшихся упражнений';

  @override
  String get total => 'Всего';

  @override
  String exerciseNum(int current, int total) {
    return 'Упражнение $current из $total';
  }

  @override
  String setNum(int current, int total) {
    return 'Подход $current из $total';
  }

  @override
  String get completedSets => 'Выполненные подходы';

  @override
  String repsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count повторения',
      many: '$count повторений',
      few: '$count повторения',
      one: '$count повторение',
    );
    return '$_temp0';
  }

  @override
  String get completeSet => 'Завершить подход';

  @override
  String get startSet => 'Начать подход';

  @override
  String get howDoYouFeel => 'Как вы себя чувствуете?';

  @override
  String get energy => 'Энергия';

  @override
  String get mood => 'Настроение';

  @override
  String get tiredness => 'Усталость';

  @override
  String get stress => 'Стресс';

  @override
  String get muscleSoreness => 'Боль в мышцах';

  @override
  String get saved => 'Сохранено';

  @override
  String get submit => 'Отправить';

  @override
  String get submitLocked => 'Отправить (заблокировано)';

  @override
  String nextEntryIn(String time) {
    return 'Следующая запись через $time';
  }

  @override
  String get recentEntries => 'Последние записи';

  @override
  String get specifyWeight => 'Укажите текущий вес';

  @override
  String get reset => 'Сбросить';

  @override
  String get challengeFeatureComingSoon => 'Функция вызова скоро появится';

  @override
  String get challenge => 'Вызов';

  @override
  String get compareFeatureComingSoon => 'Функция сравнения скоро появится';

  @override
  String get compare => 'Сравнить';

  @override
  String get messageFeatureComingSoon => 'Функция сообщений скоро появится';

  @override
  String get message => 'Сообщение';

  @override
  String get rememberMe => 'Запомнить меня';

  @override
  String errorLoadingData(String error) {
    return 'Ошибка загрузки данных: $error';
  }

  @override
  String get thirtyDays => '30 дней';

  @override
  String get ninetyDays => '90 дней';

  @override
  String get oneHundredEightyDays => '180 дней';

  @override
  String get oneYear => '1 год';

  @override
  String get customRange => 'Произвольный';

  @override
  String get selectATab => 'Выберите вкладку';

  @override
  String get noData => 'Нет данных';

  @override
  String get information => 'Информация';

  @override
  String get statistics => 'Статистика';

  @override
  String get selectExercise => 'Выберите упражнение';

  @override
  String get exerciseContributions => 'Вклад упражнений';

  @override
  String get noDataToDisplay => 'Нет данных для отображения';

  @override
  String get loadingData => 'Загрузка данных...';

  @override
  String get noDataAvailable => 'Нет доступных данных для отображения';

  @override
  String get completeOneWorkout =>
      'Выполните хотя бы одну тренировку, чтобы увидеть графики прогресса';

  @override
  String get overallStrength => 'Общая сила';

  @override
  String get bodyWeightTab => 'Вес тела';

  @override
  String get volume => 'Объём';

  @override
  String get frequency => 'Частота';

  @override
  String get consistency => 'Последовательность';

  @override
  String get exerciseProgress => 'Прогресс упражнений';

  @override
  String get progressionRecommendations => 'Рекомендации по прогрессии';

  @override
  String get notEnoughData => 'Недостаточно данных для рекомендаций';

  @override
  String get workoutComparison => 'Сравнение тренировок';

  @override
  String get detailedAnalysis => 'Детальный анализ';

  @override
  String get worldRecords => 'Мировые рекорды';

  @override
  String get allExercises => 'Все упражнения';

  @override
  String get weightLabel => 'Вес';

  @override
  String get reps => 'Повторения';

  @override
  String get date => 'Дата';

  @override
  String get oneRmEstimated => '1ПМ (расчётный)';

  @override
  String get recordHistory => 'История рекордов';

  @override
  String get allPersonalRecords => 'Все личные рекорды';

  @override
  String get federation => 'Федерация';

  @override
  String get strengthCoefficients => 'Коэффициенты силы';

  @override
  String get totalStrength => 'Общая сила';

  @override
  String get wilks => 'Уилкс';

  @override
  String get dots => 'Дотс';

  @override
  String get progressOverTime => 'Прогресс со временем';

  @override
  String get passwordResetEmailSent => 'Письмо для сброса пароля отправлено.';

  @override
  String get noWorkoutsAvailable =>
      'Нет доступных тренировок. Создайте одну в Мастерской!';

  @override
  String exercisesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count упражнения',
      many: '$count упражнений',
      few: '$count упражнения',
      one: '$count упражнение',
    );
    return '$_temp0';
  }

  @override
  String get workoutCalendar => 'Календарь тренировок';

  @override
  String get addFriend => 'Добавить друга';

  @override
  String friendRemoved(String name) {
    return '$name удалён из друзей';
  }

  @override
  String get removeFriend => 'Удалить друга';

  @override
  String get requestDeclined => 'Запрос отклонён';

  @override
  String get decline => 'Отклонить';

  @override
  String get accept => 'Принять';

  @override
  String get requestCancelled => 'Запрос отменён';

  @override
  String get pleaseEnterEmail => 'Пожалуйста, введите адрес электронной почты';

  @override
  String get friendRequestSent => 'Запрос в друзья отправлен!';

  @override
  String get sendRequest => 'Отправить запрос';

  @override
  String get darkTheme => 'Тёмная тема';

  @override
  String get profileSection => 'Профиль';

  @override
  String get profileImage => 'Изображение профиля';

  @override
  String get choosePhoto => 'Выбрать фото';

  @override
  String get deletePhoto => 'Удалить фото';

  @override
  String get profileFrame => 'Рамка профиля';

  @override
  String get programs => 'Программы';

  @override
  String openProgram(String program) {
    return 'Открыть программу: $program';
  }

  @override
  String get recentAchievements => 'Последние достижения';

  @override
  String get personalRecords => 'Личные рекорды';

  @override
  String get activity => 'Активность';

  @override
  String get streak => 'Серия';

  @override
  String get days => 'дней';

  @override
  String get totalWeightLifted => 'Всего поднято веса';

  @override
  String get wilksScore => 'Счёт Уилкс';

  @override
  String get memberSince => 'Участник с';

  @override
  String get selectAnExercise => 'Выберите упражнение для просмотра прогресса';

  @override
  String get polish => 'Polski';

  @override
  String get hideFromLeaderboards => 'Скрыть из рейтингов';

  @override
  String get hideFromLeaderboardsDesc =>
      'Ваша статистика не будет отображаться в публичных рейтингах';

  @override
  String get basicInformation => 'Основная информация';

  @override
  String get age => 'Возраст';

  @override
  String get hintAge => 'например, 25';

  @override
  String get years => 'лет';

  @override
  String get heightLabel => 'Рост';

  @override
  String get hintHeight => 'например, 175';

  @override
  String get hintWeight => 'например, 70.5';

  @override
  String get gender => 'Пол';

  @override
  String get male => 'Мужской';

  @override
  String get female => 'Женский';

  @override
  String get other => 'Другой';

  @override
  String get location => 'Местоположение';

  @override
  String get locationDesc => 'Используется для рейтингов по стране и городу';

  @override
  String get country => 'Страна';

  @override
  String get hintCountry => 'например, Россия';

  @override
  String get city => 'Город';

  @override
  String get hintCity => 'например, Москва';

  @override
  String get trainingGoals => 'Цели тренировок';

  @override
  String get trainingGoalsDesc => 'Чего вы хотите достичь?';

  @override
  String get strengthGoal => 'Сила';

  @override
  String get hypertrophyGoal => 'Гипертрофия';

  @override
  String get enduranceGoal => 'Выносливость';

  @override
  String get fatLossGoal => 'Сжигание жира';

  @override
  String get generalFitnessGoal => 'Общая физическая форма';

  @override
  String get trainingSchedule => 'График тренировок';

  @override
  String get trainingExperience => 'Опыт тренировок';

  @override
  String get hintYearsTraining => 'например, 2.5';

  @override
  String get daysPerWeek => 'Дней в неделю для тренировок';

  @override
  String get daysPerWeekDesc =>
      'Определяет, как часто рекомендуются тренировки';

  @override
  String get sessionDurationLabel => 'Типичная продолжительность сессии';

  @override
  String get sessionDurationDesc =>
      'Влияет на количество упражнений в тренировке';

  @override
  String get trainingPreferences => 'Предпочтения тренировок';

  @override
  String get experienceLevel => 'Уровень опыта';

  @override
  String get preferredIntensity => 'Предпочтительная интенсивность';

  @override
  String get intensityLight => 'Лёгкие тренировки, долгое восстановление';

  @override
  String get intensityModerate => 'Сбалансированная интенсивность и объём';

  @override
  String get intensityIntense => 'Тяжёлые тренировки, преодоление пределов';

  @override
  String get trainingFocus => 'Акцент тренировок';

  @override
  String get trainingFocusDesc =>
      'Какие группы мышц или области вы хотите приоритизировать?';

  @override
  String get hintFocus => 'например, ноги, верхнее тело, кор';

  @override
  String get injuriesLimitations => 'Травмы и ограничения';

  @override
  String get injuriesDesc =>
      'Травмы или области, которые стоит избегать? Тренировки будут учитывать это.';

  @override
  String get hintInjuries => 'например, колено, нижняя спина, плечо';

  @override
  String get pleaseSelectGoal => 'Пожалуйста, выберите хотя бы одну цель';

  @override
  String get profileSavedSuccessfully => 'Профиль успешно сохранён';

  @override
  String get nutrition => 'Питание';

  @override
  String get targets => 'Цели';

  @override
  String get meals => 'Приёмы пищи';

  @override
  String get recalculate => 'Пересчитать';

  @override
  String get setNutritionGoal => 'Установите цель питания, чтобы начать.';

  @override
  String get tapRefreshToCalculate =>
      'Нажмите кнопку обновления для расчёта целевых показателей.';

  @override
  String get algorithm => 'Алгоритм';

  @override
  String get mifflinFormula => 'Формула Миффлина-Сен Жеора';

  @override
  String get aiRecommendation => 'Рекомендация ИИ';

  @override
  String get groqModel => 'Groq - GPT-OSS 120B';

  @override
  String lastUpdated(String date) {
    return 'Последнее обновление: $date';
  }

  @override
  String get setGoalForMeals =>
      'Установите цель и рассчитайте показатели для расписания питания.';

  @override
  String get mealSchedule => 'Расписание питания';

  @override
  String mealsPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count приёма пищи в день',
      many: '$count приёмов пищи в день',
      few: '$count приёма пищи в день',
      one: '$count приём пищи в день',
    );
    return '$_temp0';
  }

  @override
  String get dailyWater => 'Дневная норма воды';

  @override
  String get nutritionGoal => 'Цель питания';

  @override
  String get notSet => 'Не установлено';

  @override
  String get mealWaterReminders => 'Напоминания о еде и воде';

  @override
  String get activeStatus => 'Активно';

  @override
  String get inactiveStatus => 'Неактивно';

  @override
  String get waterReminderInterval => 'Интервал напоминания о воде';

  @override
  String get kcalPerDay => 'ккал / день';

  @override
  String get protein => 'Белки';

  @override
  String get carbs => 'Углеводы';

  @override
  String get fat => 'Жиры';

  @override
  String get waterMacro => 'Вода';

  @override
  String goalBadge(String goal) {
    return 'Цель: $goal';
  }

  @override
  String get completeProfileFirst =>
      'Пожалуйста, сначала заполните профиль (вес, рост, возраст, пол).';

  @override
  String get aiUnavailable => 'ИИ недоступен, используется только алгоритм.';

  @override
  String get notificationDenied => 'Разрешение на уведомления отклонено.';

  @override
  String get remindersScheduled => 'Напоминания запланированы!';

  @override
  String get remindersCancelled => 'Все напоминания отменены.';

  @override
  String get any => 'Любая';

  @override
  String get primaryMuscle => 'Основная';

  @override
  String get secondaryMuscle => 'Вторичная';

  @override
  String get stabilizerMuscle => 'Стабилизатор';

  @override
  String configureExercise(String name) {
    return 'Настроить $name';
  }

  @override
  String get durationMinutes => 'Продолжительность (минуты)';

  @override
  String get editExercise => 'Изменить упражнение';

  @override
  String get deleteExercise => 'Удалить упражнение';

  @override
  String get draftRestored => 'Черновик восстановлен';

  @override
  String get exerciseAlreadyInList => 'Это упражнение уже в списке';

  @override
  String alternativeAdded(String name) {
    return 'Альтернатива добавлена: $name';
  }

  @override
  String get addAtLeastOneExercise =>
      'Пожалуйста, добавьте хотя бы одно упражнение';

  @override
  String get challenges => 'Вызовы';

  @override
  String get communityRankings => 'Рейтинг сообщества';

  @override
  String get emailLabel => 'Email';

  @override
  String get friendEmailHint => 'friend@example.com';

  @override
  String get addFriendsFirst => 'Сначала добавьте друзей для создания вызовов';

  @override
  String get mustBeLoggedIn => 'Необходимо войти в систему';

  @override
  String get challengeCreated => 'Вызов успешно создан!';

  @override
  String get requests => 'Запросы';

  @override
  String get weekA => 'Неделя A (эта неделя)';

  @override
  String get weekB => 'Неделя B (следующая неделя)';

  @override
  String get viewDetails => 'Подробнее';

  @override
  String get searchWorkouts => 'Поиск тренировок...';

  @override
  String get searchExercise => 'Поиск упражнения...';

  @override
  String get noWorkoutsAvailableCreate =>
      'Нет доступных тренировок. Создайте одну сначала.';

  @override
  String get noWorkoutsAvailableWorkshop =>
      'Нет доступных тренировок. Создайте одну в Мастерской.';

  @override
  String get apiKeySaved => 'API ключ сохранён';

  @override
  String get apiKeyRemoved => 'API ключ удалён';

  @override
  String get copiedToClipboard => 'Скопировано в буфер обмена';

  @override
  String get aiConfig => 'Настройки ИИ';

  @override
  String get yourGroqApiKey => 'Ваш Groq API ключ';

  @override
  String get exerciseLibrary => 'Библиотека упражнений';

  @override
  String get noExercisesFound => 'Упражнения не найдены';

  @override
  String get addFriendDesc =>
      'Введите email-адрес человека, которого хотите добавить в друзья.';

  @override
  String get remove => 'Удалить';

  @override
  String get apiKeyConfigured => 'API ключ настроен';

  @override
  String get noApiKeySet => 'API ключ не установлен';

  @override
  String get aiNoKeyWarning => 'Функции ИИ не будут работать без ключа';

  @override
  String get workshop => 'Мастерская';

  @override
  String get close => 'Закрыть';

  @override
  String get create => 'Создать';

  @override
  String get refresh => 'Обновить';

  @override
  String get or => 'ИЛИ';

  @override
  String get noExercisesInWorkout =>
      'В этой тренировке нет упражнений. Добавьте упражнения в Мастерской!';

  @override
  String get todaysWorkout => 'Тренировка на сегодня';

  @override
  String get workoutsThisMonth => 'Тренировок в этом месяце';

  @override
  String get dayStreak => 'Дней подряд';

  @override
  String get restDayToday => 'день отдыха сегодня';

  @override
  String get chooseOne => 'Выберите одну:';

  @override
  String get noRecommendationAvailable => 'Нет доступных рекомендаций';

  @override
  String get createWorkoutsForRecommendations =>
      'Создайте тренировки в Мастерской для персональных рекомендаций';

  @override
  String get restDayLevel => 'День отдыха';

  @override
  String get lightLevel => 'Лёгкая';

  @override
  String get moderateLevel => 'Умеренная';

  @override
  String get intenseLevel => 'Интенсивная';

  @override
  String get exercisesColonLabel => 'Упражнения:';

  @override
  String get expandWorkout => 'Развернуть';

  @override
  String get createPlanDesc =>
      'Создайте недельный план тренировок\nдля структурированного расписания.';

  @override
  String get noWorkoutsFound => 'Тренировки не найдены';

  @override
  String get noMuscleDataAvailable => 'Нет данных о мышцах';

  @override
  String get muscleLoad => 'Нагрузка на мышцы';

  @override
  String setsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подхода',
      many: '$count подходов',
      few: '$count подхода',
      one: '$count подход',
    );
    return '$_temp0';
  }

  @override
  String get selectTrainingProgram => 'Выберите программу тренировок';

  @override
  String get aiSuggested => 'Предложено ИИ';

  @override
  String get personalizedProgramsDesc =>
      'Персональные программы на основе вашей истории';

  @override
  String get noSuggestionsYet =>
      'Пока нет предложений. Сгенерируйте на основе истории тренировок!';

  @override
  String get generating => 'Генерация...';

  @override
  String get generateProgram => 'Сгенерировать программу';

  @override
  String workoutAddedToWorkouts(String name) {
    return '\"$name\" добавлена в ваши тренировки';
  }

  @override
  String get notCompletedLastTime => 'Не выполнено в прошлый раз';

  @override
  String programSelected(String name) {
    return 'Программа \"$name\" выбрана';
  }

  @override
  String get selectProgram => 'Выбрать программу';

  @override
  String get customisation => 'Кастомизация';

  @override
  String get logWorkout => 'Записать тренировку';

  @override
  String logWorkoutFor(String dayLabel) {
    return 'Записать тренировку за $dayLabel';
  }

  @override
  String get noWorkoutsOnDay => 'Нет тренировок в этот день';

  @override
  String get completed => 'Завершено';

  @override
  String get expand => 'Развернуть';

  @override
  String get collapse => 'Свернуть';

  @override
  String exerciseUpdated(String name) {
    return '$name обновлено';
  }

  @override
  String get exerciseInUse => 'Упражнение используется';

  @override
  String exerciseInUseConfirm(String name) {
    return 'Упражнение \"$name\" используется в одной или нескольких программах. Вы уверены, что хотите удалить его?';
  }

  @override
  String get deleteExerciseTitle => 'Удалить упражнение';

  @override
  String deleteExerciseConfirm(String name) {
    return 'Вы уверены, что хотите удалить \"$name\"?';
  }

  @override
  String exerciseDeleted(String name) {
    return '$name удалено';
  }

  @override
  String get noFriendsYet => 'Пока нет друзей';

  @override
  String get noFriendsDesc => 'Добавьте друзей для отслеживания их прогресса';

  @override
  String get noPendingRequests => 'Нет ожидающих запросов';

  @override
  String get receivedRequests => 'Полученные запросы';

  @override
  String get sentRequests => 'Отправленные запросы';

  @override
  String lastWorkoutDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Последняя тренировка: $days дня назад',
      many: 'Последняя тренировка: $days дней назад',
      few: 'Последняя тренировка: $days дня назад',
      one: 'Последняя тренировка: $days день назад',
    );
    return '$_temp0';
  }

  @override
  String get noWorkoutsYetFriend => 'Тренировок ещё нет';

  @override
  String weightKgDisplay(String weight) {
    return 'Вес: $weight';
  }

  @override
  String nowFriendsWith(String name) {
    return 'Вы теперь друзья с $name';
  }

  @override
  String get pending => 'Ожидает';

  @override
  String removeFriendConfirm(String name) {
    return 'Вы уверены, что хотите удалить $name из друзей?';
  }

  @override
  String get active => 'Активные';

  @override
  String get errorLoadingChallenges => 'Ошибка загрузки вызовов';

  @override
  String get noChallengesYet => 'Вызовов пока нет';

  @override
  String get createChallengeDesc =>
      'Создайте вызов для соревнования с друзьями';

  @override
  String get start => 'Начало';

  @override
  String get end => 'Конец';

  @override
  String get leaderboard => 'Таблица лидеров';

  @override
  String get createChallenge => 'Создать вызов';

  @override
  String get chooseChallengeType => 'Выберите тип вызова';

  @override
  String get selectFriends => 'Выберите друзей';

  @override
  String get selectFriendsToChallenge => 'Выберите друзей для вызова';

  @override
  String get durationDays => 'Длительность (дни)';

  @override
  String durationDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String get pleaseEnterPlanName => 'Пожалуйста, введите название плана';

  @override
  String get weeklySchedule => 'Недельное расписание';

  @override
  String get chooseOneOnDay => 'Выберите одну в этот день:';

  @override
  String get selectWorkout => 'Выберите тренировку';

  @override
  String get startingWeek => 'Начальная неделя:';

  @override
  String get muscleRecovery => 'Восстановление мышц';

  @override
  String get readyToTrain => 'Готовы к тренировке';

  @override
  String get inRecovery => 'В процессе восстановления';

  @override
  String get requireRest => 'Требуют отдыха';

  @override
  String get selectWorkoutForAnalytics =>
      'Выберите тренировку для подробной аналитики';

  @override
  String get workoutProgress => 'Прогресс тренировки';

  @override
  String get recommendedDeloadWeek => 'Рекомендуется разгрузочная неделя';

  @override
  String get completeMoreWorkouts => 'Выполните больше тренировок для анализа';

  @override
  String get improving => 'Улучшение';

  @override
  String get stable => 'Стабильно';

  @override
  String get declining => 'Снижение';

  @override
  String get startWorkout => 'Начать тренировку';

  @override
  String get noPlansYet => 'Планов пока нет';

  @override
  String get createPlan => 'Создать план';

  @override
  String get trainingPlans => 'Планы тренировок';

  @override
  String get todayFromPlan => 'Сегодня по плану';

  @override
  String get activatePlan => 'Активировать';

  @override
  String get deactivatePlan => 'Деактивировать';

  @override
  String get activeLabel => 'АКТИВЕН';

  @override
  String get deletePlan => 'Удалить план?';

  @override
  String deletePlanConfirm(String name) {
    return 'Удалить \"$name\"?';
  }

  @override
  String moreExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ ещё $count упражнения',
      many: '+ ещё $count упражнений',
      few: '+ ещё $count упражнения',
      one: '+ ещё $count упражнение',
    );
    return '$_temp0';
  }

  @override
  String get tourRestartTooltip => 'Экскурсия по приложению';

  @override
  String get tourWelcomeTitle => 'Добро пожаловать в Forge!';

  @override
  String get tourWelcomeDesc =>
      'Это краткий тур по приложению. Следуйте за подсказками, чтобы узнать обо всех функциях, которые помогут вам достичь своих фитнес-целей.';

  @override
  String get tourCalendarTitle => 'Календарь тренировок';

  @override
  String get tourCalendarDesc =>
      'Календарь показывает историю ваших тренировок. Выделенные дни - это дни с завершёнными сессиями. Нажмите на любой день, чтобы просмотреть или записать тренировку.';

  @override
  String get tourTodayWorkoutTitle => 'Тренировка дня';

  @override
  String get tourTodayWorkoutDesc =>
      'ИИ анализирует историю тренировок и восстановление, чтобы рекомендовать лучшую тренировку на сегодня. Процент уверенности показывает точность рекомендации.';

  @override
  String get tourMuscleRecoveryTitle => 'Восстановление мышц';

  @override
  String get tourMuscleRecoveryDesc =>
      'Эта карточка показывает состояние восстановления каждой группы мышц - какие готовы к тренировке, восстанавливаются или нуждаются в дополнительном отдыхе.';

  @override
  String get tourStartWorkoutTitle => 'Начать тренировку';

  @override
  String get tourStartWorkoutDesc =>
      'Нажмите эту кнопку, чтобы начать тренировочную сессию. Вы выберете из сохранённых тренировок или будете следовать активному плану.';

  @override
  String get tourStatisticsTitle => 'Статистика';

  @override
  String get tourStatisticsDesc =>
      'Отслеживайте количество тренировок в месяц и текущую серию дней. Поддерживайте серию для долгосрочной последовательности!';

  @override
  String get tourTrainingPlansTitle => 'Планы тренировок';

  @override
  String get tourTrainingPlansDesc =>
      'Создавайте структурированные недельные планы, назначая тренировки на конкретные дни. Активируйте план, чтобы автоматически следовать расписанию.';

  @override
  String get tourProfileTitle => 'Ваш профиль';

  @override
  String get tourProfileDesc =>
      'Эта вкладка содержит всю личную информацию, показатели здоровья, графики прогресса и сводку активности.';

  @override
  String get tourAboutMeTitle => 'Обо мне';

  @override
  String get tourAboutMeDesc =>
      'Заполните личные данные - возраст, рост, вес, цели тренировок и уровень опыта. Эти данные помогают ИИ персонализировать рекомендации для вас.';

  @override
  String get tourBodyWeightTitle => 'Вес тела';

  @override
  String get tourBodyWeightDesc =>
      'Регулярно записывайте вес, чтобы отслеживать изменения с течением времени. График визуализирует тенденцию и помогает следить за прогрессом.';

  @override
  String get tourWellnessTitle => 'Самочувствие';

  @override
  String get tourWellnessDesc =>
      'Записывайте ежедневное самочувствие - уровень энергии, настроение, стресс и боль в мышцах. Это помогает ИИ не перегружать вас в дни низкой энергии.';

  @override
  String get tourNutritionTitle => 'Питание';

  @override
  String get tourNutritionDesc =>
      'Установите цель по питанию и получайте персональные дневные нормы калорий, белков, углеводов и жиров. Можно включить напоминания о еде и воде.';

  @override
  String get tourAchievementsTitle => 'Достижения';

  @override
  String get tourAchievementsDesc =>
      'Получайте достижения за выполнение тренировок, установку личных рекордов и поддержание серий. Проверяйте свой прогресс здесь.';

  @override
  String get tourSettingsTitle => 'Настройки';

  @override
  String get tourSettingsDesc =>
      'Настройте приложение под себя - смените язык, единицы измерения, параметры приватности и визуальную тему.';

  @override
  String get tourFriendsTitle => 'Друзья';

  @override
  String get tourFriendsDesc =>
      'Соединяйтесь с друзьями, чтобы следить за прогрессом друг друга. Отправляйте запросы в друзья по email, просматривайте профили и сравнивайте результаты.';

  @override
  String get tourLeaderboardTitle => 'Рейтинг';

  @override
  String get tourLeaderboardDesc =>
      'Узнайте своё место в глобальном, национальном и городском рейтингах по силовым показателям. Соревнуйтесь и поднимайтесь в таблице!';

  @override
  String get tourChallengesTitle => 'Вызовы';

  @override
  String get tourChallengesDesc =>
      'Создавайте тренировочные вызовы с друзьями и соревнуйтесь в течение установленного времени. Кто сможет провести больше тренировок?';

  @override
  String get tourProgramsTitle => 'Программы';

  @override
  String get tourProgramsDesc =>
      'Здесь отображаются тренировочные программы, созданные ИИ на основе вашей истории. Выберите одну для структурированного расписания.';

  @override
  String get tourCreatePlanTitle => 'Создать план';

  @override
  String get tourCreatePlanDesc =>
      'Создайте индивидуальный недельный план, назначив тренировки на конкретные дни недели. Активируйте его, чтобы следовать структурированной рутине.';

  @override
  String get tourWorkshopTitle => 'Мастерская';

  @override
  String get tourWorkshopDesc =>
      'Мастерская - это ваш персональный зал. Создавайте и управляйте упражнениями и тренировками. Всё, что вы создаёте здесь, доступно во всём приложении.';

  @override
  String get tourExerciseLibraryTitle => 'Библиотека упражнений';

  @override
  String get tourExerciseLibraryDesc =>
      'Просматривайте сотни встроенных упражнений. Фильтруйте по группам мышц, смотрите подробные инструкции и добавляйте свои упражнения.';

  @override
  String get tourCreateWorkoutTitle => 'Создать тренировку';

  @override
  String get tourCreateWorkoutDesc =>
      'Создавайте тренировки, комбинируя упражнения из библиотеки. Настраивайте подходы, повторения и веса для каждого упражнения.';

  @override
  String get tourAiConfigTitle => 'Настройка ИИ';

  @override
  String get tourAiConfigDesc =>
      'Введите ключ Groq API здесь, чтобы разблокировать функции ИИ - персонализированные рекомендации тренировок, советы по питанию и умные программы.';

  @override
  String get tourFinishTitle => 'Всё готово!';

  @override
  String get tourFinishDesc =>
      'Теперь вы знаете ключевые функции Forge. Начните с заполнения профиля, создания первой тренировки в Мастерской и записи первой сессии. Удачи!';

  @override
  String get unitKg => 'кг';

  @override
  String get unitLb => 'lb';

  @override
  String get unitCm => 'см';

  @override
  String get heightUnitTitle => 'Рост';

  @override
  String get centimeters => 'Сантиметры (см)';

  @override
  String get feetInches => 'Футы и дюймы (ft/in)';

  @override
  String get unitFt => 'фт';

  @override
  String get unitIn => 'дюйм';

  @override
  String get addExercise => 'Добавить упражнение';

  @override
  String get addMuscleGroup => 'Добавить группу мышц';

  @override
  String get addWorkoutToDay => 'Добавить тренировку';

  @override
  String get alreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get armwrestling => 'Армрестлинг';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get createExercise => 'Создать упражнение';

  @override
  String get createWorkout => 'Создать тренировку';

  @override
  String get description => 'Описание';

  @override
  String get difficulty => 'Сложность';

  @override
  String get dontHaveAccount => 'Нет аккаунта?';

  @override
  String get editPlan => 'Редактировать план';

  @override
  String get email => 'Email';

  @override
  String get errorFieldRequired => 'Обязательное поле';

  @override
  String get errorInvalidEmail => 'Неверный формат email';

  @override
  String get errorPasswordTooShort => 'Пароль должен быть не короче 6 символов';

  @override
  String get errorPasswordsDontMatch => 'Пароли не совпадают';

  @override
  String get everyTwoWeeks => 'Раз в 2 недели';

  @override
  String get everyWeek => 'Каждую неделю';

  @override
  String get exerciseName => 'Название упражнения';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get intensityFor => 'Интенсивность для';

  @override
  String get intensityPrimary => 'Основная';

  @override
  String get intensitySecondary => 'Вспомогательная';

  @override
  String get intensityStabilizer => 'Стабилизатор';

  @override
  String get login => 'Вход';

  @override
  String get muscleGroupBack => 'Спина';

  @override
  String get muscleGroupBiceps => 'Бицепс';

  @override
  String get muscleGroupCalves => 'Икры';

  @override
  String get muscleGroupCardio => 'Кардио';

  @override
  String get muscleGroupChest => 'Грудь';

  @override
  String get muscleGroupCore => 'Кор';

  @override
  String get muscleGroupForearms => 'Предплечья';

  @override
  String get muscleGroupGlutes => 'Ягодицы';

  @override
  String get muscleGroupLegs => 'Ноги';

  @override
  String get muscleGroupShoulders => 'Плечи';

  @override
  String get muscleGroupTriceps => 'Трицепс';

  @override
  String get muscleGroupWrists => 'Запястья';

  @override
  String get muscleGroups => 'Группы мышц';

  @override
  String get name => 'Имя';

  @override
  String get noWorkoutToday => 'День отдыха';

  @override
  String get oneRepMaxFull => '1ПМ (разовый максимум)';

  @override
  String get password => 'Пароль';

  @override
  String get pickMuscleGroup => 'Выберите группу мышц';

  @override
  String get planName => 'Название плана';

  @override
  String get powerlifting => 'Пауэрлифтинг';

  @override
  String get pressToAddMuscleGroups =>
      'Нажмите кнопку ниже, чтобы добавить группы мышц';

  @override
  String get register => 'Регистрация';

  @override
  String get search => 'Поиск';

  @override
  String get sets => 'Подходы';

  @override
  String get signIn => 'Войти';

  @override
  String get signUp => 'Зарегистрироваться';

  @override
  String get streetlifting => 'Стритлифтинг';

  @override
  String get targetRepsLabel => 'Целевые повторения';

  @override
  String get trainingPlan => 'Мой план';

  @override
  String get workoutName => 'Название тренировки';

  @override
  String get pleaseEnterReps => 'Введите количество повторений';

  @override
  String get switchExercise => 'Заменить упражнение';

  @override
  String currentExerciseName(String name) {
    return 'Текущее: $name';
  }

  @override
  String get chooseAlternative => 'Выберите замену:';

  @override
  String switchedTo(String name) {
    return 'Заменено на $name';
  }

  @override
  String nextExerciseName(String name) {
    return 'Далее: $name';
  }

  @override
  String get chooseNext => 'Выбрать следующее';

  @override
  String get chooseAnyExercise => 'Любое упражнение';

  @override
  String get declineExerciseTitle => 'Отказаться от упражнения?';

  @override
  String declineExerciseConfirm(String name) {
    return '«$name» будет отмечено как пропущенное в этой тренировке и больше не появится.';
  }

  @override
  String get chooseNextExercise => 'Выберите следующее упражнение';

  @override
  String get nextByProgram => 'Следующее по программе';

  @override
  String get skipped => 'Пропущено';

  @override
  String get aiCalorieUnavailable => 'Оценка калорий ИИ недоступна.';

  @override
  String kcalBurned(int kcal) {
    return '~$kcal ккал сожжено';
  }

  @override
  String calorieEstimateUnavailable(String error) {
    return 'Оценка калорий недоступна: $error';
  }

  @override
  String get declinedLabel => 'Отказ:';

  @override
  String get finishExerciseEarlyTitle => 'Завершить упражнение досрочно?';

  @override
  String finishExerciseEarlyConfirm(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Выполнено $done из $total подходов. Завершить упражнение?',
      many: 'Выполнено $done из $total подходов. Завершить упражнение?',
      few: 'Выполнено $done из $total подходов. Завершить упражнение?',
      one: 'Выполнено $done из $total подхода. Завершить упражнение?',
    );
    return '$_temp0';
  }

  @override
  String get finish => 'Завершить';

  @override
  String get finishEarly => 'Завершить досрочно';

  @override
  String lastTimeReps(int reps) {
    String _temp0 = intl.Intl.pluralLogic(
      reps,
      locale: localeName,
      other: 'В прошлый раз: $reps повторения',
      many: 'В прошлый раз: $reps повторений',
      few: 'В прошлый раз: $reps повторения',
      one: 'В прошлый раз: $reps повторение',
    );
    return '$_temp0';
  }

  @override
  String get swap => 'Заменить';

  @override
  String get addSet => 'Добавить подход';

  @override
  String get insertExercise => 'Вставить упражнение';

  @override
  String get endWorkoutTitle => 'Завершить тренировку?';

  @override
  String get endWorkoutNoExercises =>
      'Вы не выполнили ни одного упражнения. Всё равно завершить?';

  @override
  String get endAction => 'Завершить';

  @override
  String get quickWorkout => 'Быстрая тренировка';

  @override
  String exercisesTotal(int count) {
    return 'Упражнений: $count';
  }

  @override
  String get bodyweight => 'Свой вес';

  @override
  String targetWeight(String weight) {
    return 'Цель: $weight';
  }

  @override
  String get noExercisesYet => 'Пока нет упражнений';

  @override
  String tapAddExerciseToStart(String button) {
    return 'Нажмите «$button», чтобы начать';
  }

  @override
  String get endWorkout => 'Завершить тренировку';

  @override
  String exerciseNumber(int number) {
    return 'Упражнение $number';
  }

  @override
  String weightWithUnit(String unit) {
    return 'Вес ($unit)';
  }

  @override
  String get startExercise => 'Начать упражнение';

  @override
  String fixSetTitle(int number) {
    return 'Исправить подход $number';
  }

  @override
  String recordedReps(int reps) {
    String _temp0 = intl.Intl.pluralLogic(
      reps,
      locale: localeName,
      other: 'Записано: $reps повторения',
      many: 'Записано: $reps повторений',
      few: 'Записано: $reps повторения',
      one: 'Записано: $reps повторение',
    );
    return '$_temp0';
  }

  @override
  String get fix => 'Исправить';

  @override
  String get noteOptional => 'Заметка (необязательно)';

  @override
  String get noteHint => 'Как прошло? Что изменить в следующий раз?';

  @override
  String get note => 'Заметка';

  @override
  String get today => 'сегодня';

  @override
  String moreItems(int count) {
    return 'ещё +$count...';
  }

  @override
  String repsProgress(int current, int previous) {
    return '$current / $previous повт.';
  }

  @override
  String get focusLegs => 'ноги';

  @override
  String get focusUpperBody => 'верх тела';

  @override
  String get focusCore => 'кор';

  @override
  String get focusGlutes => 'ягодицы';

  @override
  String get focusBack => 'спина';

  @override
  String get focusChest => 'грудь';

  @override
  String get focusShoulders => 'плечи';

  @override
  String get focusArms => 'руки';

  @override
  String get focusCardio => 'кардио';

  @override
  String get injuryKnee => 'колено';

  @override
  String get injuryLowerBack => 'поясница';

  @override
  String get injuryShoulder => 'плечо';

  @override
  String get injuryWrist => 'запястье';

  @override
  String get injuryElbow => 'локоть';

  @override
  String get injuryAnkle => 'голеностоп';

  @override
  String get injuryHip => 'тазобедренный сустав';

  @override
  String get injuryNeck => 'шея';

  @override
  String get injuryHamstring => 'бицепс бедра';

  @override
  String get injuryGroin => 'пах';

  @override
  String get hintWeightLb => 'напр. 155';

  @override
  String worldRecordMatchingUnavailable(String error) {
    return 'Сопоставление с мировыми рекордами недоступно: $error';
  }

  @override
  String get myRecords => 'Мои рекорды';

  @override
  String get yourRank => 'Ваш ранг';

  @override
  String get worldRecordDataUnavailable =>
      'Данные мировых рекордов недоступны — ранг обновится после загрузки.';

  @override
  String yourBest(String weight) {
    return 'Ваш лучший: $weight';
  }

  @override
  String worldRecordFederation(String federation, String weight) {
    return 'Мировой рекорд ($federation): $weight';
  }

  @override
  String weightToNextRank(String weight, String rank) {
    return '+$weight до ранга $rank';
  }

  @override
  String get maxRankAchieved => 'Достигнут максимальный ранг!';

  @override
  String get rankSystem => 'Система рангов';

  @override
  String get rankSystemDesc =>
      'На основе % от мирового рекорда в вашей весовой категории';

  @override
  String rankPercentRange(String min, String max) {
    return '$min% – $max% от мирового рекорда';
  }

  @override
  String get last30Days => 'Последние 30 дней';

  @override
  String get actualMax => 'Фактический максимум';

  @override
  String oneRepOnDate(String date) {
    return '1 повт. · $date';
  }

  @override
  String get noOneRepSets => 'Нет подходов на 1 повторение';

  @override
  String get estimated1RM => 'Расчётный 1ПМ';

  @override
  String get noWorkoutsLast30Days => 'Нет тренировок за последние 30 дней';

  @override
  String oneRmValue(String weight) {
    return '1ПМ: $weight';
  }

  @override
  String get noRecordsYet => 'Пока нет рекордов';

  @override
  String get completeWorkoutsForRecords =>
      'Выполняйте тренировки, чтобы отслеживать личные рекорды';

  @override
  String estimatedShort(String weight) {
    return 'расч. $weight';
  }

  @override
  String get yourWeightClass => 'Ваша весовая категория';

  @override
  String get coefficientsDesc =>
      'Эти коэффициенты нормируют силу относительно веса тела для честного сравнения';

  @override
  String get big3Total => 'Сумма троеборья';

  @override
  String liftsOutOfThree(int count) {
    return '$count/3 движений';
  }

  @override
  String get ratingBeginner => 'Новичок';

  @override
  String get ratingIntermediate => 'Средний';

  @override
  String get ratingAdvanced => 'Продвинутый';

  @override
  String get ratingElite => 'Элита';

  @override
  String get ratingWorldClass => 'Мировой класс';

  @override
  String get liftSquat => 'Присед';

  @override
  String get liftBenchPress => 'Жим лёжа';

  @override
  String get liftDeadlift => 'Становая тяга';

  @override
  String get strengthCoefficient => 'Коэффициент силы';

  @override
  String get aboutStrengthCoefficient => 'О коэффициенте силы';

  @override
  String get strengthCoefficientDesc =>
      'Коэффициент рассчитывается по прогрессу во ВСЕХ упражнениях. 100 — исходный уровень (ваши стартовые веса), 150 — на 50% сильнее, 200 — в 2 раза сильнее. Он отражает долгосрочное развитие силы, а не только последние тренировки.';

  @override
  String get strengthCoefficientProgress => 'Динамика коэффициента силы';

  @override
  String get currentWeight => 'Текущий вес';

  @override
  String get startingWeight => 'Начальный вес';

  @override
  String get change => 'Изменение';

  @override
  String get averageWeight => 'Средний вес';

  @override
  String get weightTrackingTip => 'Совет по учёту веса';

  @override
  String weightTrackingTipDesc(String feature) {
    return 'Для подробной истории веса регулярно обновляйте текущий вес в разделе «$feature» главного меню.';
  }

  @override
  String get periodThisWeek => 'Эта неделя';

  @override
  String get periodLast30Days => 'Последние 30 дней';

  @override
  String get periodLast90Days => 'Последние 90 дней';

  @override
  String get periodLast180Days => 'Последние 180 дней';

  @override
  String get periodLastYear => 'Последний год';

  @override
  String totalVolumeFor(String period) {
    return 'Общий объём ($period)';
  }

  @override
  String get avgPerWeek => 'Сред./нед.';

  @override
  String get weeklyVolume => 'Объём по неделям';

  @override
  String get dailyVolume => 'Объём по дням';

  @override
  String get weightHistory => 'История веса';

  @override
  String get workoutsPerWeek => 'Тренировок/нед.';

  @override
  String get totalWorkouts => 'Всего тренировок';

  @override
  String get workoutFrequencyChart => 'Частота тренировок (в неделю)';

  @override
  String get completionRate => 'Процент выполнения';

  @override
  String get setsCompleted => 'Выполнено подходов';

  @override
  String get setsPlanned => 'Запланировано подходов';

  @override
  String get workoutCompletionRate => 'Выполнение тренировок';

  @override
  String get maximumWeight => 'Максимальный вес';

  @override
  String get maximumWeightProgress => 'Динамика максимального веса';

  @override
  String get volumeWeightReps => 'Объём (вес × повторения)';

  @override
  String get intensityPercent => 'Интенсивность (%)';

  @override
  String get thousandSuffix => 'тыс.';

  @override
  String get millionSuffix => 'млн';

  @override
  String get you => 'Вы';

  @override
  String get exerciseLabel => 'Упражнение';

  @override
  String get challengeAccepted => 'Вызов принят!';

  @override
  String get challengeDeclined => 'Вызов отклонён';

  @override
  String get challengeEnded => 'Завершён';

  @override
  String daysLeft(int count) {
    return 'осталось $count дн.';
  }

  @override
  String hoursLeft(int count) {
    return 'осталось $count ч';
  }

  @override
  String minutesLeft(int count) {
    return 'осталось $count мин';
  }

  @override
  String workoutsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count тренировки',
      many: '$count тренировок',
      few: '$count тренировки',
      one: '$count тренировка',
    );
    return '$_temp0';
  }

  @override
  String get challengeWorkoutsTitle => 'Вызов на тренировки';

  @override
  String get challengeWorkoutsDesc => 'Кто выполнит больше всего тренировок?';

  @override
  String get challengeWeightTitle => 'Вызов на тоннаж';

  @override
  String get challengeWeightDesc =>
      'Кто поднимет больше всего суммарного веса?';

  @override
  String get challengeExerciseTitle => 'Вызов в упражнении';

  @override
  String get challengeExerciseDesc =>
      'Кто поднимет больше в конкретном упражнении?';

  @override
  String get challengeStreakTitle => 'Вызов на серию';

  @override
  String get challengeStreakDesc => 'Кто дольше продержит серию тренировок?';

  @override
  String get challengeConsistencyTitle => 'Вызов на регулярность';

  @override
  String get challengeConsistencyDesc => 'Кто тренируется больше дней подряд?';

  @override
  String get scopeGlobal => 'Мир';

  @override
  String get scopeMyLeague => 'Моя лига';

  @override
  String get scopeCountry => 'Страна';

  @override
  String get scopeCity => 'Город';

  @override
  String get periodAllTime => 'За всё время';

  @override
  String get periodThisMonth => 'Этот месяц';

  @override
  String get tabTotalWeight => 'Тоннаж';

  @override
  String get tabRecords => 'Рекорды';

  @override
  String get setCountryForRankings =>
      'Укажите страну в Профиль → Обо мне, чтобы видеть рейтинг страны';

  @override
  String get setCityForRankings =>
      'Укажите город в Профиль → Обо мне, чтобы видеть рейтинг города';

  @override
  String get addFriendsForLeague =>
      'Добавьте друзей, чтобы видеть рейтинг лиги';

  @override
  String get noDataYet => 'Пока нет данных';

  @override
  String get exerciseColon => 'Упражнение:';

  @override
  String get selectAnExerciseShort => 'Выберите упражнение';

  @override
  String get noRecord => 'Нет рекорда';

  @override
  String errorWithMessage(String error) {
    return 'Ошибка: $error';
  }

  @override
  String get matchPoor => 'Слабое совпадение';

  @override
  String get matchFair => 'Неплохое совпадение';

  @override
  String get matchModerate => 'Среднее совпадение';

  @override
  String get matchGood => 'Хорошее совпадение';

  @override
  String get matchGreat => 'Отличное совпадение';

  @override
  String get quickWorkoutDesc =>
      'Нет плана? Просто начните — добавляйте упражнения по ходу';

  @override
  String get noSavedWorkoutsYet => 'Пока нет сохранённых тренировок';

  @override
  String get createInWorkshopOrQuick =>
      'Создайте тренировку в Мастерской или начните быструю тренировку выше';

  @override
  String get recommendedForToday => 'Рекомендовано на сегодня';

  @override
  String get allWorkouts => 'Все тренировки';

  @override
  String get preview => 'Просмотр';

  @override
  String get progressionRecommendationsTitle => 'Рекомендации по прогрессии';

  @override
  String get recommendedDeloadDesc =>
      'Последние тренировки были тяжёлыми. Снизьте нагрузку для восстановления.';

  @override
  String get current => 'Сейчас';

  @override
  String get suggested => 'Предложено';

  @override
  String get reasonForChange => 'Причина изменения:';

  @override
  String get completedInRecentWorkouts => 'Выполнено в последних тренировках:';

  @override
  String get averageWeightColon => 'Средний вес:';

  @override
  String get averageRepsColon => 'Среднее число повторений:';

  @override
  String get estimated1RMColon => 'Расчётный 1ПМ:';

  @override
  String get weightTrendColon => 'Динамика веса:';

  @override
  String trendRising(String delta) {
    return '↑ Растёт ($delta)';
  }

  @override
  String trendFalling(String delta) {
    return '↓ Снижается ($delta)';
  }

  @override
  String get trendStable => '→ Стабильно';

  @override
  String get daysSinceLastSession => 'Дней с последней тренировки:';

  @override
  String get generateProgramFailed =>
      'Не удалось создать программу. Проверьте API-ключ или подключение к интернету.';

  @override
  String get bodyweightTraining => 'Тренировки с собственным весом';

  @override
  String get specializedTraining => 'Специализированные тренировки';

  @override
  String get maxStrengthPrograms => 'Программы для максимальной силы';

  @override
  String get approve => 'Принять';

  @override
  String get aiEvaluation => 'Оценка ИИ';

  @override
  String get evalEmptySummary => 'Пустая тренировка';

  @override
  String get evalEmptyDetail =>
      'Добавьте упражнения, чтобы получить оценку ИИ.';

  @override
  String get evalExcellentSummary => 'Отличная тренировка!';

  @override
  String evalExcellentDetail(int count) {
    return 'Хорошая структура, сбалансированная нагрузка на группы мышц ($count). Удачный объём.';
  }

  @override
  String get evalGoodSummary => 'Хорошая тренировка.';

  @override
  String evalGoodDetailFocus(String group) {
    return 'Крепкая структура с акцентом на: $group. Небольшие правки улучшат баланс.';
  }

  @override
  String get evalGoodDetail =>
      'Крепкая структура. Небольшие правки улучшат баланс.';

  @override
  String get evalAverageSummary => 'Средняя тренировка.';

  @override
  String get evalAverageDetailFew =>
      'Добавьте больше упражнений для лучшего стимула.';

  @override
  String get evalAverageDetail => 'Можно улучшить объём или баланс мышц.';

  @override
  String get evalWeakSummary => 'Нужно доработать.';

  @override
  String get evalWeakDetailLowVolume =>
      'Очень малый объём — добавьте подходов для ощутимого стимула.';

  @override
  String get evalWeakDetailImbalanced =>
      'Сильный перекос нагрузки. Распределите упражнения на больше групп мышц.';

  @override
  String get evalPoorSummary => 'Слабая структура тренировки.';

  @override
  String get evalPoorDetail =>
      'Сильный дисбаланс или недостаточный объём. Пересоберите план.';

  @override
  String daysShort(int count) {
    return '$count дн.';
  }

  @override
  String exerciseUpdatedName(String name) {
    return 'Упражнение обновлено: $name';
  }

  @override
  String exerciseAddedName(String name) {
    return 'Упражнение добавлено: $name';
  }

  @override
  String get typeWeightReps => 'Вес + повторения';

  @override
  String get typeRepsOnly => 'Только повторения';

  @override
  String get typeCardio => 'Кардио';

  @override
  String get editWorkout => 'Редактировать тренировку';

  @override
  String get draft => 'Черновик';

  @override
  String get noExercisesAddedYet => 'Упражнения ещё не добавлены';

  @override
  String get tapPlusToAddExercises => 'Нажмите +, чтобы добавить упражнения';

  @override
  String minutesShort(int count) {
    return '$count мин';
  }

  @override
  String alternativeN(int number, String name) {
    return 'Замена $number: $name';
  }

  @override
  String get addAlternative => 'Добавить замену';

  @override
  String get completeWellnessForRecommendation =>
      'Пройдите опрос самочувствия, чтобы получить рекомендацию';

  @override
  String wellnessAverage(String avg, String answers) {
    return 'Сред.: $avg — $answers';
  }

  @override
  String get todaysRecommendation => 'Рекомендация на сегодня';

  @override
  String exercisesWithCount(int count) {
    return 'Упражнения ($count)';
  }

  @override
  String overallConfidence(String percent) {
    return 'Общая уверенность: $percent%';
  }

  @override
  String get privateProfile => 'Закрытый профиль';

  @override
  String privateProfileDesc(String name) {
    return 'У пользователя $name закрытый профиль.\nВидны только имя и аватар.';
  }

  @override
  String get rank => 'Ранг';

  @override
  String get totalVolume => 'Общий объём';

  @override
  String tonnesShort(String value) {
    return '$value т';
  }

  @override
  String get compareStats => 'Сравнить статистику';

  @override
  String challengeFriend(String name) {
    return 'Вызов: $name';
  }

  @override
  String challengeSentTo(String name) {
    return 'Вызов отправлен: $name!';
  }

  @override
  String get statsComparison => 'Сравнение статистики';

  @override
  String get currentStreak => 'Текущая серия';

  @override
  String get youInParens => '(Вы)';

  @override
  String aheadBy(String diff, String percent) {
    return 'Вы впереди на $diff ($percent%)';
  }

  @override
  String behindBy(String diff, String percent) {
    return 'Отставание на $diff ($percent%)';
  }

  @override
  String get notAvailable => 'Н/Д';

  @override
  String unlockedOfTotal(int unlocked, int total) {
    return 'Открыто $unlocked из $total';
  }

  @override
  String get tabAll => 'Все';

  @override
  String get tabStrength => 'Сила';

  @override
  String get tabSocial => 'Социальные';

  @override
  String get tabSpecial => 'Особые';

  @override
  String get noAchievementsInCategory => 'В этой категории нет достижений';

  @override
  String unlockedOn(String date) {
    return 'Открыто $date';
  }

  @override
  String get unlocked => 'Открыто';

  @override
  String get userNamePlaceholder => 'Имя пользователя';

  @override
  String get selectWorkoutForAnalyticsHint =>
      'Выберите тренировку для подробной аналитики';

  @override
  String kcalValue(String value) {
    return '$value ккал';
  }

  @override
  String get nutritionGoalQuestion => 'Какая у вас цель по питанию?';

  @override
  String get nutritionGoalDesc =>
      'От этого зависят дневная норма калорий и распределение БЖУ.';

  @override
  String get confirmGoal => 'Подтвердить цель';

  @override
  String get enabled => 'Включено';

  @override
  String get disabled => 'Выключено';

  @override
  String get choosePrimaryColor => 'Выберите основной цвет приложения';

  @override
  String get exerciseType => 'Тип упражнения';

  @override
  String get exerciseTypeDesc =>
      'Определяет, какие показатели записываются на тренировке';

  @override
  String get typeWeightRepsDesc => 'Подходы, повторения и вес';

  @override
  String get typeRepsOnlyDesc => 'Подходы и повторения, без веса';

  @override
  String get typeCardioDesc => 'Только длительность';

  @override
  String get chooseTrainingDirection => 'Выберите направление';

  @override
  String get aiProgramGeneration => 'Генерация программы ИИ';

  @override
  String get aiProgramGenerationDesc =>
      'ИИ подстроит программу под ваши цели и историю тренировок';

  @override
  String get selectDirection => 'Выберите направление';

  @override
  String get directionFullBody => 'Всё тело';

  @override
  String get directionFullBodyDesc =>
      'Сбалансированное развитие всех групп мышц';

  @override
  String get directionPowerliftingDesc =>
      'Максимальная сила: присед, жим, тяга';

  @override
  String get directionArmWrestlingDesc =>
      'Предплечья, запястья, хват и тяговая сила';

  @override
  String get directionStreetliftingDesc =>
      'Калистеника с отягощением и навыки с собственным весом';

  @override
  String get testing => 'Проверка...';

  @override
  String get testKey => 'Проверить ключ';

  @override
  String get howToGetApiKey => 'Как получить бесплатный API-ключ';

  @override
  String get apiKeyStep1 =>
      'Откройте console.groq.com и зарегистрируйтесь (бесплатно)';

  @override
  String get apiKeyStep2 => 'Откройте «API Keys» в меню слева';

  @override
  String get apiKeyStep3 => 'Нажмите «Create API Key» и задайте имя';

  @override
  String get apiKeyStep4 => 'Скопируйте ключ и вставьте сюда';

  @override
  String get apiKeyFreeTier =>
      'Бесплатного лимита с запасом хватает для личного использования.';

  @override
  String get readyToTrainColon => 'Готовы к тренировке:';

  @override
  String get chooseAWorkout => 'Выберите тренировку:';

  @override
  String macroProteinShort(String grams) {
    return 'Б: $grams г';
  }

  @override
  String macroCarbsShort(String grams) {
    return 'У: $grams г';
  }

  @override
  String macroFatShort(String grams) {
    return 'Ж: $grams г';
  }

  @override
  String waterAmount(String liters, String ml) {
    return '$liters л  ($ml мл)';
  }

  @override
  String confidencePercent(int percent) {
    return 'уверенность $percent%';
  }

  @override
  String withWeight(String weight) {
    return ' с весом $weight';
  }

  @override
  String topPercentOfAthletes(String percent) {
    return 'Топ $percent% атлетов';
  }

  @override
  String get nice => 'Отлично!';

  @override
  String get rankWooden => 'Деревянный';

  @override
  String get rankStone => 'Каменный';

  @override
  String get rankIron => 'Железный';

  @override
  String get rankBronze => 'Бронзовый';

  @override
  String get rankSilver => 'Серебряный';

  @override
  String get rankGold => 'Золотой';

  @override
  String get rankDiamond => 'Алмазный';

  @override
  String get goalAggressiveFatLoss => 'Интенсивное похудение';

  @override
  String get goalFatLoss => 'Похудение';

  @override
  String get goalMaintain => 'Поддержание веса';

  @override
  String get goalLeanBulk => 'Чистый набор';

  @override
  String get goalBulk => 'Набор массы';

  @override
  String get goalAggressiveFatLossDesc =>
      'Большой дефицит для быстрого похудения. -500 ккал/день.';

  @override
  String get goalFatLossDesc =>
      'Умеренный дефицит для плавного похудения. -300 ккал/день.';

  @override
  String get goalMaintainDesc =>
      'Питание на уровне поддержки для сохранения веса.';

  @override
  String get goalLeanBulkDesc =>
      'Небольшой профицит для набора мышц с минимумом жира. +250 ккал/день.';

  @override
  String get goalBulkDesc =>
      'Значительный профицит для максимального роста мышц. +500 ккал/день.';

  @override
  String get mealBreakfast => 'Завтрак';

  @override
  String get mealLunch => 'Обед';

  @override
  String get mealDinner => 'Ужин';

  @override
  String get mealAfternoonSnack => 'Полдник';

  @override
  String get mealMidMorningSnack => 'Второй завтрак';

  @override
  String notifMealTitle(String meal) {
    return '🍽 Пора: $meal';
  }

  @override
  String notifMealBody(String kcal, String protein) {
    return '$kcal ккал · $protein г белка';
  }

  @override
  String get notifMealChannel => 'Напоминания о еде';

  @override
  String get notifWaterTitle => '💧 Пора выпить воды';

  @override
  String get notifWaterBody => 'Пейте воду — тело скажет спасибо!';

  @override
  String get notifWaterChannel => 'Напоминания о воде';

  @override
  String get recoveryReallyNeedTrain => 'Очень пора тренировать!';

  @override
  String get recoveryDefinitelyTime => 'Точно пора тренировать';

  @override
  String get recoveryTrainedToday => 'Тренировались сегодня — отдых';

  @override
  String recoveryProgress(int days, int optimal) {
    return 'Восстановление ($days/$optimal дн.)';
  }

  @override
  String get recoveryGoodTime => 'Хорошее время для тренировки';

  @override
  String recoveryLongTime(int days) {
    return 'Давно не тренировали ($days дн.)';
  }

  @override
  String get standardProgression => 'Стандартная прогрессия';

  @override
  String get reasonDeloadRecommended =>
      'Рекомендована разгрузочная неделя для восстановления';

  @override
  String get reasonRestTrainedYesterday =>
      'День отдыха — вы тренировались вчера';

  @override
  String get reasonRestWellness =>
      'День отдыха — по самочувствию нужно восстановление';

  @override
  String get reasonRestOverall => 'По общему состоянию рекомендован отдых';

  @override
  String get reasonHighReadiness =>
      'Высокая готовность — отличный день для тренировки';

  @override
  String get reasonGoodReadiness => 'Хорошая готовность к умеренной тренировке';

  @override
  String get reasonLightTraining => 'Сегодня рекомендована лёгкая тренировка';

  @override
  String reasonDaysSinceWorkout(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days дня с последней тренировки — хорошее восстановление',
      many: '$days дней с последней тренировки — хорошее восстановление',
      few: '$days дня с последней тренировки — хорошее восстановление',
      one: '$days день с последней тренировки — хорошее восстановление',
    );
    return '$_temp0';
  }

  @override
  String get reasonWellRecovered =>
      'Хорошо восстановились после прошлой тренировки';

  @override
  String get reasonOneDayRecovery =>
      'Один день восстановления — интенсивность скорректирована';

  @override
  String reasonReadyToTrain(String muscles) {
    return 'Готовы к тренировке: $muscles';
  }

  @override
  String reasonRequireRest(String muscles) {
    return 'Нуждаются в отдыхе: $muscles';
  }

  @override
  String get reasonHighSoreness => 'Сильная крепатура — веса скорректированы';

  @override
  String get reasonLowEnergy => 'Мало энергии — стоит снизить интенсивность';

  @override
  String get reasonGoodEnergy => 'Хороший уровень энергии';

  @override
  String get progNoHistory => 'Нет истории — используются параметры программы';

  @override
  String get progNewExercise =>
      'Новое упражнение — параметры подобраны под ваши цели';

  @override
  String get progDeload => 'Разгрузочная неделя — 90% от прошлого веса';

  @override
  String progExcellentReps(String reps) {
    return 'Отличный результат — цель +$reps повт.';
  }

  @override
  String get progAddingSet => 'Хороший прогресс — добавляем подход';

  @override
  String get progMaintainReps =>
      'Тяжёлая тренировка — сохраняем повторения прошлой';

  @override
  String get progBodyweightMaintain =>
      'Упражнение с собственным весом — сохраняем уровень';

  @override
  String get progWellnessReduced => 'Нагрузка снижена — учтено самочувствие';

  @override
  String get progLimitedRecovery =>
      'Неполное восстановление — сохраняем прошлый вес';

  @override
  String progTrendingUp(String delta) {
    return 'Рост — $delta по данным за месяц';
  }

  @override
  String get progLoadReduced => 'Нагрузка снижена по последней динамике';

  @override
  String get progStable => 'Стабильно — сохраняем прошлый вес';

  @override
  String get progWellnessConsidered => ' (с учётом самочувствия)';

  @override
  String get popupRankUpTitle => 'Новый ранг!';

  @override
  String popupRankUpMessage(String rank) {
    return 'Вы достигли ранга «$rank».';
  }

  @override
  String get popupGreatProgressTitle => 'Отличный прогресс!';

  @override
  String get popupGreatProgressMessage => 'Ваш общий рейтинг быстро растёт.';

  @override
  String get popupNewRecordTitle => 'Новый личный рекорд!';

  @override
  String get popupFirstWorkoutTitle => 'Первая тренировка завершена!';

  @override
  String get popupFirstWorkoutMessage => 'Добро пожаловать в путь к силе.';

  @override
  String get rankReasonConsistency => 'регулярности тренировок и достижениях';

  @override
  String rankReasonLifts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count отслеживаемых упражнениях относительно мировых рекордов',
      many: '$count отслеживаемых упражнениях относительно мировых рекордов',
      few: '$count отслеживаемых упражнениях относительно мировых рекордов',
      one: '$count отслеживаемом упражнении относительно мировых рекордов',
    );
    return '$_temp0';
  }

  @override
  String rankReasonSummary(String basis, int workouts, int streak) {
    return 'На основе данных о $basis; тренировок: $workouts, серия: $streak дн.';
  }

  @override
  String get rankReasonNotEnough =>
      'Пока мало истории тренировок — ранг уточнится по мере новых тренировок.';

  @override
  String get errMustBeLoggedInFriends =>
      'Войдите, чтобы отправлять заявки в друзья';

  @override
  String get errCannotAddYourself => 'Нельзя добавить себя в друзья';

  @override
  String get errNoUserWithEmail => 'Пользователь с таким email не найден';

  @override
  String get errAlreadyFriends => 'Вы уже друзья с этим пользователем';

  @override
  String get errRequestAlreadySent => 'Заявка уже отправлена';

  @override
  String get errSendRequestFailed =>
      'Не удалось отправить заявку. Попробуйте ещё раз.';

  @override
  String get errUserDataNotFound => 'Данные пользователя не найдены';

  @override
  String get errAcceptRequestFailed =>
      'Не удалось принять заявку. Попробуйте ещё раз.';

  @override
  String get errRejectRequestFailed =>
      'Не удалось отклонить заявку. Попробуйте ещё раз.';

  @override
  String get errRemoveFriendFailed =>
      'Не удалось удалить из друзей. Попробуйте ещё раз.';

  @override
  String get errCancelRequestFailed =>
      'Не удалось отменить заявку. Попробуйте ещё раз.';

  @override
  String get errCreateChallengeFailed =>
      'Не удалось создать вызов. Попробуйте ещё раз.';

  @override
  String get errAcceptChallengeFailed => 'Не удалось принять вызов';

  @override
  String get errDeclineChallengeFailed => 'Не удалось отклонить вызов';

  @override
  String get errRegistrationFailed => 'Ошибка регистрации.';

  @override
  String get errWeakPassword => 'Слишком простой пароль.';

  @override
  String get errEmailInUse => 'Этот email уже используется.';

  @override
  String get errInvalidEmailAuth => 'Неверный адрес email.';

  @override
  String get errSignInFailed => 'Не удалось войти.';

  @override
  String get errUserNotFound => 'Пользователь с таким email не найден.';

  @override
  String get errWrongPassword => 'Неверный пароль.';

  @override
  String get errUserDisabled => 'Этот пользователь заблокирован.';

  @override
  String minutesValue(int count) {
    return '$count мин';
  }

  @override
  String get achFirstWorkoutTitle => 'Первые шаги';

  @override
  String get achFirstWorkoutDesc => 'Завершите первую тренировку';

  @override
  String get achWorkout10Title => 'Начало положено';

  @override
  String get achWorkout50Title => 'Целеустремлённый';

  @override
  String get achWorkout100Title => 'Сотня';

  @override
  String get achWorkout500Title => 'Легенда';

  @override
  String achCompleteWorkouts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Завершите $count тренировки',
      many: 'Завершите $count тренировок',
      few: 'Завершите $count тренировки',
      one: 'Завершите $count тренировку',
    );
    return '$_temp0';
  }

  @override
  String get achWeight1000Title => 'Лёгкий вес';

  @override
  String get achWeight10000Title => 'Тяжеловес';

  @override
  String get achWeight100000Title => 'Железный воин';

  @override
  String achLiftTotal(String weight) {
    return 'Поднимите в сумме $weight';
  }

  @override
  String get achWilks300Title => 'Сильный';

  @override
  String get achWilks400Title => 'Элитная сила';

  @override
  String achReachWilks(int value) {
    return 'Достигните $value по Уилксу';
  }

  @override
  String get achStreak7Title => 'Воин недели';

  @override
  String get achStreak30Title => 'Мастер месяца';

  @override
  String get achStreak100Title => 'Неудержимый';

  @override
  String achTrainDaysInRow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Тренируйтесь $count дня подряд',
      many: 'Тренируйтесь $count дней подряд',
      few: 'Тренируйтесь $count дня подряд',
      one: 'Тренируйтесь $count день подряд',
    );
    return '$_temp0';
  }

  @override
  String get achEarlyBirdTitle => 'Ранняя пташка';

  @override
  String get achEarlyBirdDesc => 'Завершите 10 тренировок до 8 утра';

  @override
  String get achNightOwlTitle => 'Ночная сова';

  @override
  String get achNightOwlDesc => 'Завершите 10 тренировок после 20:00';

  @override
  String get achFirstFriendTitle => 'Общительный';

  @override
  String get achFirstFriendDesc => 'Добавьте первого друга';

  @override
  String get achFriends10Title => 'Популярный';

  @override
  String get achFriends10Desc => 'Заведите 10 друзей';

  @override
  String get achChallengeWinnerTitle => 'Чемпион';

  @override
  String get achChallengeWinnerDesc => 'Выиграйте первый вызов';

  @override
  String get achChallenge5Title => 'Соперник';

  @override
  String get achChallenge5Desc => 'Завершите 5 вызовов';

  @override
  String get achNewYearTitle => 'Новый год — новый я';

  @override
  String get achNewYearDesc => 'Потренируйтесь 1 января';

  @override
  String get achBirthdayTitle => 'Прогресс на день рождения';

  @override
  String get achBirthdayDesc => 'Потренируйтесь в свой день рождения';

  @override
  String get achPerfectWeekTitle => 'Идеальная неделя';

  @override
  String get achPerfectWeekDesc =>
      'Выполните все запланированные тренировки за неделю';

  @override
  String get measurements => 'Замеры';

  @override
  String get measurementShoulders => 'Плечевой пояс';

  @override
  String get measurementChest => 'Грудь';

  @override
  String get measurementBicepsRight => 'Правый бицепс';

  @override
  String get measurementBicepsLeft => 'Левый бицепс';

  @override
  String get measurementForearmRight => 'Правое предплечье';

  @override
  String get measurementForearmLeft => 'Левое предплечье';

  @override
  String get measurementThighRight => 'Правое бедро';

  @override
  String get measurementThighLeft => 'Левое бедро';

  @override
  String get measurementCalfRight => 'Правая икра';

  @override
  String get measurementCalfLeft => 'Левая икра';

  @override
  String get measurementsHint =>
      'Нажмите на кольцо вокруг тела, чтобы указать обхват';

  @override
  String get measurementCircumference => 'Обхват';

  @override
  String measurementInvalid(String min, String max) {
    return 'Введите значение от $min до $max';
  }

  @override
  String measurementUpdated(String date) {
    return 'Последнее обновление: $date';
  }

  @override
  String get challengesSocial => 'Общественные';

  @override
  String get challengesPersonal => 'Личные';

  @override
  String get challengeYourself => 'Челлендж самому себе';

  @override
  String get challengeYourselfHint =>
      'Не выбирайте никого, чтобы бросить вызов только себе.';

  @override
  String get personalChallengesIntro =>
      'Системные челленджи с проверкой по камере. Поставьте телефон так, чтобы было видно всё тело.';

  @override
  String get exercisePushUps => 'Отжимания';

  @override
  String personalBest(int count) {
    return 'Рекорд: $count';
  }

  @override
  String get personalChallengeDone => 'Выполнено';

  @override
  String get startAttempt => 'Начать';

  @override
  String get poseCameraTitle => 'Отслеживание позы';

  @override
  String get poseSwitchCamera => 'Сменить камеру';

  @override
  String get poseStartRecording => 'Начать запись';

  @override
  String get poseStopRecording => 'Остановить запись';

  @override
  String get poseLoadingModel => 'Загрузка модели…';

  @override
  String get poseNoPerson => 'Отойдите, чтобы всё тело было в кадре';

  @override
  String poseLandmarksVisible(int count) {
    return 'Точки: $count/33';
  }

  @override
  String poseCameraError(String error) {
    return 'Ошибка камеры: $error';
  }

  @override
  String get poseNoCamera => 'На устройстве нет доступной камеры';

  @override
  String get poseCameraPermissionDenied =>
      'Нет доступа к камере. Разрешите его в настройках системы.';

  @override
  String get poseRepCounterSoon =>
      'Автоматический подсчёт повторений скоро появится';

  @override
  String poseTarget(int count) {
    return 'Цель: $count';
  }

  @override
  String get poseRecordingSaved => 'Запись сохранена';

  @override
  String get poseDeleteRecording => 'Удалить';

  @override
  String get poseKeepRecording => 'Оставить';
}
