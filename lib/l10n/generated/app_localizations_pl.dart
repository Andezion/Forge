import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'Forge';

  @override
  String get profile => 'Profil';

  @override
  String get home => 'Główna';

  @override
  String get workout => 'Trening';

  @override
  String get friends => 'Znajomi';

  @override
  String get calendar => 'Kalendarz';

  @override
  String get progress => 'Postęp';

  @override
  String get workouts => 'Treningi';

  @override
  String get bodyWeight => 'Masa ciała';

  @override
  String get wellness => 'Samopoczucie';

  @override
  String get oneRepMax => 'Kalkulator 1PM';

  @override
  String get logout => 'Wyloguj';

  @override
  String get done => 'Gotowe';

  @override
  String get cancel => 'Anuluj';

  @override
  String get save => 'Zapisz';

  @override
  String get delete => 'Usuń';

  @override
  String get edit => 'Edytuj';

  @override
  String get add => 'Dodaj';

  @override
  String get skip => 'Pomiń';

  @override
  String get next => 'Dalej';

  @override
  String get back => 'Wstecz';

  @override
  String get settings => 'Ustawienia';

  @override
  String get customization => 'Dostosowanie';

  @override
  String get achievements => 'Osiągnięcia';

  @override
  String get progressCharts => 'Wykresy postępu';

  @override
  String get aboutMe => 'O mnie';

  @override
  String get easy => 'Łatwy';

  @override
  String get medium => 'Średni';

  @override
  String get hard => 'Trudny';

  @override
  String get profileInformation => 'Informacje o profilu';

  @override
  String get nickname => 'Pseudonim';

  @override
  String get region => 'Region';

  @override
  String get language => 'Język';

  @override
  String get unitsOfMeasurement => 'Jednostki miary';

  @override
  String get weight => 'Waga';

  @override
  String get distance => 'Dystans';

  @override
  String get privacySettings => 'Ustawienia prywatności';

  @override
  String get publicProfile => 'Publiczny profil';

  @override
  String get publicProfileDesc =>
      'Pozwól innym zobaczyć informacje o Twoim profilu';

  @override
  String get showWorkoutHistory => 'Pokaż historię treningów';

  @override
  String get showWorkoutHistoryDesc => 'Wyświetlaj historię treningów znajomym';

  @override
  String get showPersonalRecords => 'Pokaż rekordy osobiste';

  @override
  String get showPersonalRecordsDesc =>
      'Pozwól innym zobaczyć Twoje rekordy osobiste';

  @override
  String get allowFriendRequests => 'Zezwól na zaproszenia do znajomych';

  @override
  String get allowFriendRequestsDesc =>
      'Pozwól innym wysyłać Ci zaproszenia do znajomych';

  @override
  String get saveProfileInfo => 'Zapisz informacje o profilu';

  @override
  String get profileInfoSaved => 'Informacje o profilu zapisane!';

  @override
  String get themeColorUpdated => 'Kolor motywu zaktualizowany!';

  @override
  String get darkThemeEnabled => 'Ciemny motyw włączony';

  @override
  String get lightThemeEnabled => 'Jasny motyw włączony';

  @override
  String get enterNickname => 'Wprowadź pseudonim';

  @override
  String get enterRegion => 'np. Polska, Europa, Azja';

  @override
  String get kilograms => 'Kilogramy (kg)';

  @override
  String get pounds => 'Funty (lb)';

  @override
  String get meters => 'Metry (m)';

  @override
  String get feet => 'Stopy (ft)';

  @override
  String get english => 'English';

  @override
  String get russian => 'Русский';

  @override
  String workoutSaved(String name) {
    return 'Trening zapisany: $name';
  }

  @override
  String get deleteWorkout => 'Usuń trening';

  @override
  String deleteWorkoutConfirm(String name) {
    return 'Czy na pewno chcesz usunąć \"$name\"?';
  }

  @override
  String get workoutCompleted => 'Trening zakończony!';

  @override
  String get createYourWorkout => 'Stwórz swój trening';

  @override
  String get customizeTrainingProgram => 'Dostosuj swój program treningowy';

  @override
  String get createNewWorkout => 'Utwórz nowy trening';

  @override
  String get myWorkouts => 'Moje treningi';

  @override
  String get noWorkoutsYet => 'Brak treningów. Stwórz swój pierwszy!';

  @override
  String get exitWorkout => 'Wyjść z treningu?';

  @override
  String get progressWillBeLost => 'Twój postęp zostanie utracony.';

  @override
  String get exit => 'Wyjdź';

  @override
  String setComplete(int number) {
    return 'Seria $number zakończona';
  }

  @override
  String targetReps(int reps) {
    String _temp0 = intl.Intl.pluralLogic(
      reps,
      locale: localeName,
      other: 'Cel: $reps powtórzenia',
      many: 'Cel: $reps powtórzeń',
      few: 'Cel: $reps powtórzenia',
      one: 'Cel: $reps powtórzenie',
    );
    return '$_temp0';
  }

  @override
  String get howWasExercise => 'Jak było to ćwiczenie?';

  @override
  String get workoutComplete => 'Trening zakończony!';

  @override
  String duration(String time) {
    return 'Czas: $time';
  }

  @override
  String completedExercises(int count) {
    return 'Ukończone: $count';
  }

  @override
  String get skippedExercises => 'Pominięte ćwiczenia:';

  @override
  String get noRemainingExercises => 'Brak pozostałych ćwiczeń';

  @override
  String get total => 'Łącznie';

  @override
  String exerciseNum(int current, int total) {
    return 'Ćwiczenie $current z $total';
  }

  @override
  String setNum(int current, int total) {
    return 'Seria $current z $total';
  }

  @override
  String get completedSets => 'Ukończone serie';

  @override
  String repsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count powtórzenia',
      many: '$count powtórzeń',
      few: '$count powtórzenia',
      one: '1 powtórzenie',
    );
    return '$_temp0';
  }

  @override
  String get completeSet => 'Zakończ serię';

  @override
  String get startSet => 'Rozpocznij serię';

  @override
  String get howDoYouFeel => 'Jak się czujesz?';

  @override
  String get energy => 'Energia';

  @override
  String get mood => 'Nastrój';

  @override
  String get tiredness => 'Zmęczenie';

  @override
  String get stress => 'Stres';

  @override
  String get muscleSoreness => 'Ból mięśni';

  @override
  String get saved => 'Zapisano';

  @override
  String get submit => 'Wyślij';

  @override
  String get submitLocked => 'Wyślij (zablokowane)';

  @override
  String nextEntryIn(String time) {
    return 'Następny wpis za $time';
  }

  @override
  String get recentEntries => 'Ostatnie wpisy';

  @override
  String get specifyWeight => 'Podaj aktualną wagę';

  @override
  String get reset => 'Resetuj';

  @override
  String get challengeFeatureComingSoon => 'Funkcja wyzwań wkrótce';

  @override
  String get challenge => 'Wyzwanie';

  @override
  String get compareFeatureComingSoon => 'Funkcja porównania wkrótce';

  @override
  String get compare => 'Porównaj';

  @override
  String get messageFeatureComingSoon => 'Funkcja wiadomości wkrótce';

  @override
  String get message => 'Wiadomość';

  @override
  String get rememberMe => 'Zapamiętaj mnie';

  @override
  String errorLoadingData(String error) {
    return 'Błąd ładowania danych: $error';
  }

  @override
  String get thirtyDays => '30 dni';

  @override
  String get ninetyDays => '90 dni';

  @override
  String get oneHundredEightyDays => '180 dni';

  @override
  String get oneYear => '1 rok';

  @override
  String get customRange => 'Niestandardowy';

  @override
  String get selectATab => 'Wybierz zakładkę';

  @override
  String get noData => 'Brak danych';

  @override
  String get information => 'Informacje';

  @override
  String get statistics => 'Statystyki';

  @override
  String get selectExercise => 'Wybierz ćwiczenie';

  @override
  String get exerciseContributions => 'Udział ćwiczeń';

  @override
  String get noDataToDisplay => 'Brak danych do wyświetlenia';

  @override
  String get loadingData => 'Ładowanie danych...';

  @override
  String get noDataAvailable => 'Brak dostępnych danych do wyświetlenia';

  @override
  String get completeOneWorkout =>
      'Ukończ co najmniej jeden trening, aby zobaczyć wykresy postępu';

  @override
  String get overallStrength => 'Ogólna siła';

  @override
  String get bodyWeightTab => 'Masa ciała';

  @override
  String get volume => 'Objętość';

  @override
  String get frequency => 'Częstotliwość';

  @override
  String get consistency => 'Konsekwencja';

  @override
  String get exerciseProgress => 'Postęp ćwiczeń';

  @override
  String get progressionRecommendations => 'Zalecenia progresji';

  @override
  String get notEnoughData => 'Niewystarczające dane dla zaleceń';

  @override
  String get workoutComparison => 'Porównanie treningów';

  @override
  String get detailedAnalysis => 'Szczegółowa analiza';

  @override
  String get worldRecords => 'Rekordy świata';

  @override
  String get allExercises => 'Wszystkie ćwiczenia';

  @override
  String get weightLabel => 'Waga';

  @override
  String get reps => 'Powtórzenia';

  @override
  String get date => 'Data';

  @override
  String get oneRmEstimated => '1PM (szacowany)';

  @override
  String get recordHistory => 'Historia rekordów';

  @override
  String get allPersonalRecords => 'Wszystkie rekordy osobiste';

  @override
  String get federation => 'Federacja';

  @override
  String get strengthCoefficients => 'Współczynniki siły';

  @override
  String get totalStrength => 'Łączna siła';

  @override
  String get wilks => 'Wilks';

  @override
  String get dots => 'Dots';

  @override
  String get progressOverTime => 'Postęp w czasie';

  @override
  String get passwordResetEmailSent => 'Email resetowania hasła wysłany.';

  @override
  String get noWorkoutsAvailable =>
      'Brak dostępnych treningów. Utwórz jeden w Warsztacie!';

  @override
  String exercisesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ćwiczenia',
      many: '$count ćwiczeń',
      few: '$count ćwiczenia',
      one: '$count ćwiczenie',
    );
    return '$_temp0';
  }

  @override
  String get workoutCalendar => 'Kalendarz treningów';

  @override
  String get addFriend => 'Dodaj znajomego';

  @override
  String friendRemoved(String name) {
    return '$name usunięty ze znajomych';
  }

  @override
  String get removeFriend => 'Usuń znajomego';

  @override
  String get requestDeclined => 'Zaproszenie odrzucone';

  @override
  String get decline => 'Odrzuć';

  @override
  String get accept => 'Akceptuj';

  @override
  String get requestCancelled => 'Zaproszenie anulowane';

  @override
  String get pleaseEnterEmail => 'Proszę podać adres e-mail';

  @override
  String get friendRequestSent => 'Zaproszenie do znajomych wysłane!';

  @override
  String get sendRequest => 'Wyślij zaproszenie';

  @override
  String get darkTheme => 'Ciemny motyw';

  @override
  String get profileSection => 'Profil';

  @override
  String get profileImage => 'Zdjęcie profilowe';

  @override
  String get choosePhoto => 'Wybierz zdjęcie';

  @override
  String get deletePhoto => 'Usuń zdjęcie';

  @override
  String get profileFrame => 'Ramka profilu';

  @override
  String get programs => 'Programy';

  @override
  String openProgram(String program) {
    return 'Otwórz program: $program';
  }

  @override
  String get recentAchievements => 'Ostatnie osiągnięcia';

  @override
  String get personalRecords => 'Rekordy osobiste';

  @override
  String get activity => 'Aktywność';

  @override
  String get streak => 'Seria';

  @override
  String get days => 'dni';

  @override
  String get totalWeightLifted => 'Łączny podniesiony ciężar';

  @override
  String get wilksScore => 'Wynik Wilks';

  @override
  String get memberSince => 'Członek od';

  @override
  String get selectAnExercise => 'Wybierz ćwiczenie, aby zobaczyć postęp';

  @override
  String get polish => 'Polski';

  @override
  String get hideFromLeaderboards => 'Ukryj z rankingów';

  @override
  String get hideFromLeaderboardsDesc =>
      'Twoje statystyki nie będą widoczne w publicznych rankingach';

  @override
  String get basicInformation => 'Podstawowe informacje';

  @override
  String get age => 'Wiek';

  @override
  String get hintAge => 'np. 25';

  @override
  String get years => 'lat';

  @override
  String get heightLabel => 'Wzrost';

  @override
  String get hintHeight => 'np. 175';

  @override
  String get hintWeight => 'np. 70.5';

  @override
  String get gender => 'Płeć';

  @override
  String get male => 'Mężczyzna';

  @override
  String get female => 'Kobieta';

  @override
  String get other => 'Inne';

  @override
  String get location => 'Lokalizacja';

  @override
  String get locationDesc => 'Używane do rankingów krajowych i miejskich';

  @override
  String get country => 'Kraj';

  @override
  String get hintCountry => 'np. Polska';

  @override
  String get city => 'Miasto';

  @override
  String get hintCity => 'np. Warszawa';

  @override
  String get trainingGoals => 'Cele treningowe';

  @override
  String get trainingGoalsDesc => 'Co chcesz osiągnąć?';

  @override
  String get strengthGoal => 'Siła';

  @override
  String get hypertrophyGoal => 'Hipertrofia';

  @override
  String get enduranceGoal => 'Wytrzymałość';

  @override
  String get fatLossGoal => 'Redukcja tłuszczu';

  @override
  String get generalFitnessGoal => 'Ogólna sprawność';

  @override
  String get trainingSchedule => 'Harmonogram treningów';

  @override
  String get trainingExperience => 'Doświadczenie treningowe';

  @override
  String get hintYearsTraining => 'np. 2.5';

  @override
  String get daysPerWeek => 'Dni treningowe w tygodniu';

  @override
  String get daysPerWeekDesc => 'Określa jak często treningi są zalecane';

  @override
  String get sessionDurationLabel => 'Typowy czas sesji';

  @override
  String get sessionDurationDesc => 'Wpływa na liczbę ćwiczeń w treningu';

  @override
  String get trainingPreferences => 'Preferencje treningowe';

  @override
  String get experienceLevel => 'Poziom doświadczenia';

  @override
  String get preferredIntensity => 'Preferowana intensywność';

  @override
  String get intensityLight => 'Łatwiejsze treningi, dłuższa regeneracja';

  @override
  String get intensityModerate => 'Zrównoważona intensywność i objętość';

  @override
  String get intensityIntense => 'Wymagające treningi, przekraczanie limitów';

  @override
  String get trainingFocus => 'Obszar treningowy';

  @override
  String get trainingFocusDesc =>
      'Jakie grupy mięśniowe chcesz priorytetyzować?';

  @override
  String get hintFocus => 'np. nogi, górne partie, brzuch';

  @override
  String get injuriesLimitations => 'Urazy i ograniczenia';

  @override
  String get injuriesDesc =>
      'Urazy lub obszary do unikania? Treningi będą to uwzględniać.';

  @override
  String get hintInjuries => 'np. kolano, dolny kręgosłup, ramię';

  @override
  String get pleaseSelectGoal => 'Proszę wybrać co najmniej jeden cel';

  @override
  String get profileSavedSuccessfully => 'Profil zapisany pomyślnie';

  @override
  String get nutrition => 'Odżywianie';

  @override
  String get targets => 'Cele';

  @override
  String get meals => 'Posiłki';

  @override
  String get recalculate => 'Przelicz';

  @override
  String get setNutritionGoal => 'Ustaw cel żywieniowy, aby rozpocząć.';

  @override
  String get tapRefreshToCalculate =>
      'Naciśnij przycisk odświeżania, aby obliczyć cele.';

  @override
  String get algorithm => 'Algorytm';

  @override
  String get mifflinFormula => 'Formuła Mifflina-St Jeora';

  @override
  String get aiRecommendation => 'Rekomendacja AI';

  @override
  String get groqModel => 'Groq - GPT-OSS 120B';

  @override
  String lastUpdated(String date) {
    return 'Ostatnia aktualizacja: $date';
  }

  @override
  String get setGoalForMeals =>
      'Ustaw cel i oblicz wskaźniki, aby zobaczyć harmonogram posiłków.';

  @override
  String get mealSchedule => 'Harmonogram posiłków';

  @override
  String mealsPerDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count posiłki dziennie',
      many: '$count posiłków dziennie',
      few: '$count posiłki dziennie',
      one: '$count posiłek dziennie',
    );
    return '$_temp0';
  }

  @override
  String get dailyWater => 'Dzienna norma wody';

  @override
  String get nutritionGoal => 'Cel żywieniowy';

  @override
  String get notSet => 'Nie ustawiono';

  @override
  String get mealWaterReminders => 'Przypomnienia o posiłkach i wodzie';

  @override
  String get activeStatus => 'Aktywne';

  @override
  String get inactiveStatus => 'Nieaktywne';

  @override
  String get waterReminderInterval => 'Interwał przypomnienia o wodzie';

  @override
  String get kcalPerDay => 'kcal / dzień';

  @override
  String get protein => 'Białko';

  @override
  String get carbs => 'Węglowodany';

  @override
  String get fat => 'Tłuszcze';

  @override
  String get waterMacro => 'Woda';

  @override
  String goalBadge(String goal) {
    return 'Cel: $goal';
  }

  @override
  String get completeProfileFirst =>
      'Proszę najpierw uzupełnić profil (waga, wzrost, wiek, płeć).';

  @override
  String get aiUnavailable => 'AI niedostępne, używam tylko algorytmu.';

  @override
  String get notificationDenied => 'Brak uprawnień do powiadomień.';

  @override
  String get remindersScheduled => 'Przypomnienia zaplanowane!';

  @override
  String get remindersCancelled => 'Wszystkie przypomnienia anulowane.';

  @override
  String get any => 'Dowolna';

  @override
  String get primaryMuscle => 'Główna';

  @override
  String get secondaryMuscle => 'Dodatkowa';

  @override
  String get stabilizerMuscle => 'Stabilizator';

  @override
  String configureExercise(String name) {
    return 'Skonfiguruj $name';
  }

  @override
  String get durationMinutes => 'Czas trwania (minuty)';

  @override
  String get editExercise => 'Edytuj ćwiczenie';

  @override
  String get deleteExercise => 'Usuń ćwiczenie';

  @override
  String get draftRestored => 'Szkic przywrócony';

  @override
  String get exerciseAlreadyInList => 'To ćwiczenie jest już na liście';

  @override
  String alternativeAdded(String name) {
    return 'Alternatywa dodana: $name';
  }

  @override
  String get addAtLeastOneExercise =>
      'Proszę dodać co najmniej jedno ćwiczenie';

  @override
  String get challenges => 'Wyzwania';

  @override
  String get communityRankings => 'Rankingi społeczności';

  @override
  String get emailLabel => 'Email';

  @override
  String get friendEmailHint => 'znajomy@example.com';

  @override
  String get addFriendsFirst =>
      'Najpierw dodaj znajomych, aby tworzyć wyzwania';

  @override
  String get mustBeLoggedIn => 'Musisz być zalogowany';

  @override
  String get challengeCreated => 'Wyzwanie pomyślnie utworzone!';

  @override
  String get requests => 'Zaproszenia';

  @override
  String get weekA => 'Tydzień A (ten tydzień)';

  @override
  String get weekB => 'Tydzień B (następny tydzień)';

  @override
  String get viewDetails => 'Szczegóły';

  @override
  String get searchWorkouts => 'Szukaj treningów...';

  @override
  String get searchExercise => 'Szukaj ćwiczenia...';

  @override
  String get noWorkoutsAvailableCreate =>
      'Brak dostępnych treningów. Utwórz najpierw jeden.';

  @override
  String get noWorkoutsAvailableWorkshop =>
      'Brak dostępnych treningów. Utwórz jeden w Warsztacie.';

  @override
  String get apiKeySaved => 'Klucz API zapisany';

  @override
  String get apiKeyRemoved => 'Klucz API usunięty';

  @override
  String get copiedToClipboard => 'Skopiowano do schowka';

  @override
  String get aiConfig => 'Konfiguracja AI';

  @override
  String get yourGroqApiKey => 'Twój klucz API Groq';

  @override
  String get exerciseLibrary => 'Biblioteka ćwiczeń';

  @override
  String get noExercisesFound => 'Nie znaleziono ćwiczeń';

  @override
  String get addFriendDesc =>
      'Wpisz adres e-mail osoby, którą chcesz dodać jako znajomego.';

  @override
  String get remove => 'Usuń';

  @override
  String get apiKeyConfigured => 'Klucz API skonfigurowany';

  @override
  String get noApiKeySet => 'Brak klucza API';

  @override
  String get aiNoKeyWarning => 'Funkcje AI nie będą działać bez klucza';

  @override
  String get workshop => 'Warsztat';

  @override
  String get close => 'Zamknij';

  @override
  String get create => 'Utwórz';

  @override
  String get refresh => 'Odśwież';

  @override
  String get or => 'LUB';

  @override
  String get noExercisesInWorkout =>
      'Ten trening nie ma ćwiczeń. Dodaj ćwiczenia w Warsztacie!';

  @override
  String get todaysWorkout => 'Trening na dziś';

  @override
  String get workoutsThisMonth => 'Treningi w tym miesiącu';

  @override
  String get dayStreak => 'Dni z rzędu';

  @override
  String get restDayToday => 'dzień odpoczynku dzisiaj';

  @override
  String get chooseOne => 'Wybierz jeden:';

  @override
  String get noRecommendationAvailable => 'Brak dostępnych rekomendacji';

  @override
  String get createWorkoutsForRecommendations =>
      'Utwórz treningi w Warsztacie, aby otrzymywać spersonalizowane rekomendacje';

  @override
  String get restDayLevel => 'Dzień odpoczynku';

  @override
  String get lightLevel => 'Lekki';

  @override
  String get moderateLevel => 'Umiarkowany';

  @override
  String get intenseLevel => 'Intensywny';

  @override
  String get exercisesColonLabel => 'Ćwiczenia:';

  @override
  String get expandWorkout => 'Rozwiń';

  @override
  String get createPlanDesc =>
      'Utwórz tygodniowy plan treningów\naby mieć ustrukturyzowany harmonogram.';

  @override
  String get noWorkoutsFound => 'Nie znaleziono treningów';

  @override
  String get noMuscleDataAvailable => 'Brak danych o mięśniach';

  @override
  String get muscleLoad => 'Obciążenie mięśni';

  @override
  String setsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count serie',
      many: '$count serii',
      few: '$count serie',
      one: '$count seria',
    );
    return '$_temp0';
  }

  @override
  String get selectTrainingProgram => 'Wybierz program treningowy';

  @override
  String get aiSuggested => 'Sugerowane przez AI';

  @override
  String get personalizedProgramsDesc =>
      'Spersonalizowane programy na podstawie Twojej historii';

  @override
  String get noSuggestionsYet =>
      'Brak sugestii. Wygeneruj je na podstawie historii treningów!';

  @override
  String get generating => 'Generowanie...';

  @override
  String get generateProgram => 'Generuj program';

  @override
  String workoutAddedToWorkouts(String name) {
    return '\"$name\" dodano do Twoich treningów';
  }

  @override
  String get notCompletedLastTime => 'Nie ukończono ostatnim razem';

  @override
  String programSelected(String name) {
    return 'Program \"$name\" wybrany';
  }

  @override
  String get selectProgram => 'Wybierz program';

  @override
  String get customisation => 'Personalizacja';

  @override
  String get logWorkout => 'Zapisz trening';

  @override
  String logWorkoutFor(String dayLabel) {
    return 'Zapisz trening za $dayLabel';
  }

  @override
  String get noWorkoutsOnDay => 'Brak treningów w tym dniu';

  @override
  String get completed => 'Ukończono';

  @override
  String get expand => 'Rozwiń';

  @override
  String get collapse => 'Zwiń';

  @override
  String exerciseUpdated(String name) {
    return '$name zaktualizowano';
  }

  @override
  String get exerciseInUse => 'Ćwiczenie w użyciu';

  @override
  String exerciseInUseConfirm(String name) {
    return 'Ćwiczenie \"$name\" jest używane w jednym lub kilku programach treningowych. Czy na pewno chcesz je usunąć?';
  }

  @override
  String get deleteExerciseTitle => 'Usuń ćwiczenie';

  @override
  String deleteExerciseConfirm(String name) {
    return 'Czy na pewno chcesz usunąć \"$name\"?';
  }

  @override
  String exerciseDeleted(String name) {
    return '$name usunięto';
  }

  @override
  String get noFriendsYet => 'Brak znajomych';

  @override
  String get noFriendsDesc => 'Dodaj znajomych, aby śledzić ich postępy';

  @override
  String get noPendingRequests => 'Brak oczekujących zaproszeń';

  @override
  String get receivedRequests => 'Otrzymane zaproszenia';

  @override
  String get sentRequests => 'Wysłane zaproszenia';

  @override
  String lastWorkoutDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Ostatni trening: $days dni temu',
      many: 'Ostatni trening: $days dni temu',
      few: 'Ostatni trening: $days dni temu',
      one: 'Ostatni trening: $days dzień temu',
    );
    return '$_temp0';
  }

  @override
  String get noWorkoutsYetFriend => 'Brak treningów';

  @override
  String weightKgDisplay(String weight) {
    return 'Waga: $weight';
  }

  @override
  String nowFriendsWith(String name) {
    return 'Jesteś teraz znajomym z $name';
  }

  @override
  String get pending => 'Oczekuje';

  @override
  String removeFriendConfirm(String name) {
    return 'Czy na pewno chcesz usunąć $name ze znajomych?';
  }

  @override
  String get active => 'Aktywne';

  @override
  String get errorLoadingChallenges => 'Błąd ładowania wyzwań';

  @override
  String get noChallengesYet => 'Brak wyzwań';

  @override
  String get createChallengeDesc =>
      'Utwórz wyzwanie, aby rywalizować ze znajomymi';

  @override
  String get start => 'Start';

  @override
  String get end => 'Koniec';

  @override
  String get leaderboard => 'Tabela liderów';

  @override
  String get createChallenge => 'Utwórz wyzwanie';

  @override
  String get chooseChallengeType => 'Wybierz typ wyzwania';

  @override
  String get selectFriends => 'Wybierz znajomych';

  @override
  String get selectFriendsToChallenge => 'Wybierz znajomych do wyzwania';

  @override
  String get durationDays => 'Czas trwania (dni)';

  @override
  String durationDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dni',
      many: '$count dni',
      few: '$count dni',
      one: '$count dzień',
    );
    return '$_temp0';
  }

  @override
  String get pleaseEnterPlanName => 'Proszę wpisać nazwę planu';

  @override
  String get weeklySchedule => 'Tygodniowy harmonogram';

  @override
  String get chooseOneOnDay => 'Wybierz jeden na ten dzień:';

  @override
  String get selectWorkout => 'Wybierz trening';

  @override
  String get startingWeek => 'Tydzień startowy:';

  @override
  String get muscleRecovery => 'Regeneracja mięśni';

  @override
  String get readyToTrain => 'Gotowe do treningu';

  @override
  String get inRecovery => 'W trakcie regeneracji';

  @override
  String get requireRest => 'Wymagają odpoczynku';

  @override
  String get selectWorkoutForAnalytics =>
      'Wybierz trening, aby zobaczyć szczegółową analizę';

  @override
  String get workoutProgress => 'Postęp treningu';

  @override
  String get recommendedDeloadWeek => 'Zalecany tydzień odciążenia';

  @override
  String get completeMoreWorkouts => 'Ukończ więcej treningów dla analizy';

  @override
  String get improving => 'Poprawa';

  @override
  String get stable => 'Stabilnie';

  @override
  String get declining => 'Spadek';

  @override
  String get startWorkout => 'Rozpocznij trening';

  @override
  String get noPlansYet => 'Brak planów';

  @override
  String get createPlan => 'Utwórz plan';

  @override
  String get trainingPlans => 'Plany treningowe';

  @override
  String get todayFromPlan => 'Dzisiaj z planu';

  @override
  String get activatePlan => 'Aktywuj';

  @override
  String get deactivatePlan => 'Dezaktywuj';

  @override
  String get activeLabel => 'AKTYWNY';

  @override
  String get deletePlan => 'Usunąć plan?';

  @override
  String deletePlanConfirm(String name) {
    return 'Usunąć \"$name\"?';
  }

  @override
  String moreExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ jeszcze $count ćwiczenia',
      many: '+ jeszcze $count ćwiczeń',
      few: '+ jeszcze $count ćwiczenia',
      one: '+ jeszcze $count ćwiczenie',
    );
    return '$_temp0';
  }

  @override
  String get tourRestartTooltip => 'Przewodnik po aplikacji';

  @override
  String get tourWelcomeTitle => 'Witaj w Forge!';

  @override
  String get tourWelcomeDesc =>
      'To krótki przewodnik po aplikacji. Śledź podpowiedzi, aby odkryć wszystkie funkcje, które pomogą Ci osiągnąć cele treningowe.';

  @override
  String get tourCalendarTitle => 'Kalendarz treningów';

  @override
  String get tourCalendarDesc =>
      'Kalendarz pokazuje historię Twoich treningów. Zaznaczone dni mają ukończone sesje. Dotknij dowolnego dnia, aby zobaczyć lub zapisać trening.';

  @override
  String get tourTodayWorkoutTitle => 'Trening na dziś';

  @override
  String get tourTodayWorkoutDesc =>
      'AI analizuje historię treningów i regenerację, aby polecić najlepszy trening na dziś. Procent pewności pokazuje trafność rekomendacji.';

  @override
  String get tourMuscleRecoveryTitle => 'Regeneracja mięśni';

  @override
  String get tourMuscleRecoveryDesc =>
      'Ta karta pokazuje stan regeneracji każdej grupy mięśni - które są gotowe do treningu, w trakcie regeneracji lub wymagają dodatkowego odpoczynku.';

  @override
  String get tourStartWorkoutTitle => 'Rozpocznij trening';

  @override
  String get tourStartWorkoutDesc =>
      'Dotknij tego przycisku, aby rozpocząć sesję treningową. Wybierzesz spośród zapisanych treningów lub będziesz śledzić aktywny plan.';

  @override
  String get tourStatisticsTitle => 'Statystyki';

  @override
  String get tourStatisticsDesc =>
      'Śledź liczbę treningów w miesiącu i aktualną serię dni. Utrzymuj serię, aby budować długoterminową konsekwencję!';

  @override
  String get tourTrainingPlansTitle => 'Plany treningowe';

  @override
  String get tourTrainingPlansDesc =>
      'Twórz ustrukturyzowane plany tygodniowe, przypisując treningi do konkretnych dni. Aktywuj plan, aby automatycznie podążać za harmonogramem.';

  @override
  String get tourProfileTitle => 'Twój profil';

  @override
  String get tourProfileDesc =>
      'Ta zakładka zawiera wszystkie informacje osobiste, wskaźniki zdrowia, wykresy postępu i podsumowanie aktywności.';

  @override
  String get tourAboutMeTitle => 'O mnie';

  @override
  String get tourAboutMeDesc =>
      'Uzupełnij dane osobowe - wiek, wzrost, wagę, cele treningowe i poziom doświadczenia. Te dane pomagają AI personalizować rekomendacje.';

  @override
  String get tourBodyWeightTitle => 'Masa ciała';

  @override
  String get tourBodyWeightDesc =>
      'Regularnie zapisuj swoją wagę, aby śledzić zmiany w czasie. Wykres wizualizuje trend wagowy i pomaga monitorować postępy.';

  @override
  String get tourWellnessTitle => 'Samopoczucie';

  @override
  String get tourWellnessDesc =>
      'Zapisuj codzienne samopoczucie - poziom energii, nastrój, stres i ból mięśni. Pomaga to AI unikać nadmiernego obciążenia w dniach niskiej energii.';

  @override
  String get tourNutritionTitle => 'Żywienie';

  @override
  String get tourNutritionDesc =>
      'Ustaw cel żywieniowy i otrzymuj spersonalizowane dzienne normy kalorii, białka, węglowodanów i tłuszczy. Możesz też włączyć przypomnienia o posiłkach i wodzie.';

  @override
  String get tourAchievementsTitle => 'Osiągnięcia';

  @override
  String get tourAchievementsDesc =>
      'Zdobywaj osiągnięcia za ukończenie treningów, pobicie rekordów osobistych i utrzymywanie serii. Sprawdź swój postęp tutaj.';

  @override
  String get tourSettingsTitle => 'Ustawienia';

  @override
  String get tourSettingsDesc =>
      'Dostosuj aplikację do swoich preferencji - zmień język, jednostki miary, ustawienia prywatności i motyw wizualny.';

  @override
  String get tourFriendsTitle => 'Znajomi';

  @override
  String get tourFriendsDesc =>
      'Połącz się ze znajomymi, aby śledzić nawzajem swoje postępy. Wysyłaj zaproszenia e-mailem, przeglądaj profile i porównuj wyniki.';

  @override
  String get tourLeaderboardTitle => 'Ranking';

  @override
  String get tourLeaderboardDesc =>
      'Sprawdź swoje miejsce w globalnych, krajowych i miejskich rankingach według wskaźników siły. Rywalizuj i wspinaj się w tabeli!';

  @override
  String get tourChallengesTitle => 'Wyzwania';

  @override
  String get tourChallengesDesc =>
      'Twórz wyzwania treningowe ze znajomymi i rywalizuj przez ustalony czas. Kto ukończy więcej sesji?';

  @override
  String get tourProgramsTitle => 'Programy';

  @override
  String get tourProgramsDesc =>
      'Tutaj znajdziesz programy treningowe wygenerowane przez AI na podstawie Twojej historii. Wybierz jeden, aby uzyskać ustrukturyzowany harmonogram.';

  @override
  String get tourCreatePlanTitle => 'Utwórz plan';

  @override
  String get tourCreatePlanDesc =>
      'Zbuduj niestandardowy tygodniowy plan, przypisując treningi do konkretnych dni tygodnia. Aktywuj go, aby podążać za ustrukturyzowaną rutyną.';

  @override
  String get tourWorkshopTitle => 'Warsztat';

  @override
  String get tourWorkshopDesc =>
      'Warsztat to Twoja osobista siłownia - twórz i zarządzaj ćwiczeniami i treningami. Wszystko, co tu stworzysz, jest dostępne w całej aplikacji.';

  @override
  String get tourExerciseLibraryTitle => 'Biblioteka ćwiczeń';

  @override
  String get tourExerciseLibraryDesc =>
      'Przeglądaj setki wbudowanych ćwiczeń. Filtruj według grupy mięśni, przeglądaj szczegółowe instrukcje i dodawaj własne ćwiczenia.';

  @override
  String get tourCreateWorkoutTitle => 'Utwórz trening';

  @override
  String get tourCreateWorkoutDesc =>
      'Buduj treningi, łącząc ćwiczenia z biblioteki. Skonfiguruj serie, powtórzenia i wagi dla każdego ćwiczenia zgodnie ze swoim stylem.';

  @override
  String get tourAiConfigTitle => 'Konfiguracja AI';

  @override
  String get tourAiConfigDesc =>
      'Wprowadź swój klucz API Groq, aby odblokować funkcje AI - spersonalizowane rekomendacje treningowe, porady żywieniowe i inteligentne programy.';

  @override
  String get tourFinishTitle => 'Gotowe!';

  @override
  String get tourFinishDesc =>
      'Znasz już kluczowe funkcje Forge. Zacznij od uzupełnienia profilu, stworzenia pierwszego treningu w Warsztacie i zapisania pierwszej sesji. Powodzenia!';

  @override
  String get unitKg => 'kg';

  @override
  String get unitLb => 'lb';

  @override
  String get unitCm => 'cm';

  @override
  String get heightUnitTitle => 'Wzrost';

  @override
  String get centimeters => 'Centymetry (cm)';

  @override
  String get feetInches => 'Stopy i cale (ft/in)';

  @override
  String get unitFt => 'ft';

  @override
  String get unitIn => 'in';

  @override
  String get addExercise => 'Dodaj ćwiczenie';

  @override
  String get addMuscleGroup => 'Dodaj grupę mięśni';

  @override
  String get addWorkoutToDay => 'Dodaj trening';

  @override
  String get alreadyHaveAccount => 'Masz już konto?';

  @override
  String get armwrestling => 'Armwrestling';

  @override
  String get confirmPassword => 'Potwierdź hasło';

  @override
  String get createExercise => 'Utwórz ćwiczenie';

  @override
  String get createWorkout => 'Utwórz trening';

  @override
  String get description => 'Opis';

  @override
  String get difficulty => 'Trudność';

  @override
  String get dontHaveAccount => 'Nie masz konta?';

  @override
  String get editPlan => 'Edytuj plan';

  @override
  String get email => 'E-mail';

  @override
  String get errorFieldRequired => 'To pole jest wymagane';

  @override
  String get errorInvalidEmail => 'Nieprawidłowy format e-maila';

  @override
  String get errorPasswordTooShort => 'Hasło musi mieć co najmniej 6 znaków';

  @override
  String get errorPasswordsDontMatch => 'Hasła nie są zgodne';

  @override
  String get everyTwoWeeks => 'Co 2 tygodnie';

  @override
  String get everyWeek => 'Co tydzień';

  @override
  String get exerciseName => 'Nazwa ćwiczenia';

  @override
  String get forgotPassword => 'Nie pamiętasz hasła?';

  @override
  String get intensityFor => 'Intensywność dla';

  @override
  String get intensityPrimary => 'Główna';

  @override
  String get intensitySecondary => 'Pomocnicza';

  @override
  String get intensityStabilizer => 'Stabilizator';

  @override
  String get login => 'Logowanie';

  @override
  String get muscleGroupBack => 'Plecy';

  @override
  String get muscleGroupBiceps => 'Biceps';

  @override
  String get muscleGroupCalves => 'Łydki';

  @override
  String get muscleGroupCardio => 'Cardio';

  @override
  String get muscleGroupChest => 'Klatka piersiowa';

  @override
  String get muscleGroupCore => 'Core';

  @override
  String get muscleGroupForearms => 'Przedramiona';

  @override
  String get muscleGroupGlutes => 'Pośladki';

  @override
  String get muscleGroupLegs => 'Nogi';

  @override
  String get muscleGroupShoulders => 'Barki';

  @override
  String get muscleGroupTriceps => 'Triceps';

  @override
  String get muscleGroupWrists => 'Nadgarstki';

  @override
  String get muscleGroups => 'Grupy mięśni';

  @override
  String get name => 'Imię';

  @override
  String get noWorkoutToday => 'Dzień odpoczynku';

  @override
  String get oneRepMaxFull => '1RM (maksimum na jedno powtórzenie)';

  @override
  String get password => 'Hasło';

  @override
  String get pickMuscleGroup => 'Wybierz grupę mięśni';

  @override
  String get planName => 'Nazwa planu';

  @override
  String get powerlifting => 'Trójbój siłowy';

  @override
  String get pressToAddMuscleGroups =>
      'Naciśnij przycisk poniżej, aby dodać grupy mięśni';

  @override
  String get register => 'Rejestracja';

  @override
  String get search => 'Szukaj';

  @override
  String get sets => 'Serie';

  @override
  String get signIn => 'Zaloguj się';

  @override
  String get signUp => 'Zarejestruj się';

  @override
  String get streetlifting => 'Streetlifting';

  @override
  String get targetRepsLabel => 'Docelowe powtórzenia';

  @override
  String get trainingPlan => 'Mój plan';

  @override
  String get workoutName => 'Nazwa treningu';

  @override
  String get pleaseEnterReps => 'Podaj liczbę powtórzeń';

  @override
  String get switchExercise => 'Zamień ćwiczenie';

  @override
  String currentExerciseName(String name) {
    return 'Obecne: $name';
  }

  @override
  String get chooseAlternative => 'Wybierz zamiennik:';

  @override
  String switchedTo(String name) {
    return 'Zamieniono na $name';
  }

  @override
  String nextExerciseName(String name) {
    return 'Następne: $name';
  }

  @override
  String get chooseNext => 'Wybierz następne';

  @override
  String get chooseAnyExercise => 'Dowolne ćwiczenie';

  @override
  String get declineExerciseTitle => 'Odrzucić ćwiczenie?';

  @override
  String declineExerciseConfirm(String name) {
    return '„$name” zostanie oznaczone jako pominięte w tej sesji i nie pojawi się ponownie.';
  }

  @override
  String get chooseNextExercise => 'Wybierz następne ćwiczenie';

  @override
  String get nextByProgram => 'Następne wg programu';

  @override
  String get skipped => 'Pominięte';

  @override
  String get aiCalorieUnavailable =>
      'Szacowanie kalorii przez AI jest niedostępne.';

  @override
  String kcalBurned(int kcal) {
    return '~$kcal kcal spalonych';
  }

  @override
  String calorieEstimateUnavailable(String error) {
    return 'Szacowanie kalorii niedostępne: $error';
  }

  @override
  String get declinedLabel => 'Odrzucone:';

  @override
  String get finishExerciseEarlyTitle => 'Zakończyć ćwiczenie wcześniej?';

  @override
  String finishExerciseEarlyConfirm(int done, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Ukończono $done z $total serii. Zakończyć ćwiczenie?',
      many: 'Ukończono $done z $total serii. Zakończyć ćwiczenie?',
      few: 'Ukończono $done z $total serii. Zakończyć ćwiczenie?',
      one: 'Ukończono $done z $total serii. Zakończyć ćwiczenie?',
    );
    return '$_temp0';
  }

  @override
  String get finish => 'Zakończ';

  @override
  String get finishEarly => 'Zakończ wcześniej';

  @override
  String lastTimeReps(int reps) {
    String _temp0 = intl.Intl.pluralLogic(
      reps,
      locale: localeName,
      other: 'Ostatnio: $reps powtórzenia',
      many: 'Ostatnio: $reps powtórzeń',
      few: 'Ostatnio: $reps powtórzenia',
      one: 'Ostatnio: $reps powtórzenie',
    );
    return '$_temp0';
  }

  @override
  String get swap => 'Zamień';

  @override
  String get addSet => 'Dodaj serię';

  @override
  String get insertExercise => 'Wstaw ćwiczenie';

  @override
  String get endWorkoutTitle => 'Zakończyć trening?';

  @override
  String get endWorkoutNoExercises =>
      'Nie ukończono żadnego ćwiczenia. Zakończyć mimo to?';

  @override
  String get endAction => 'Zakończ';

  @override
  String get quickWorkout => 'Szybki trening';

  @override
  String exercisesTotal(int count) {
    return 'Ćwiczenia: $count';
  }

  @override
  String get bodyweight => 'Masa ciała';

  @override
  String targetWeight(String weight) {
    return 'Cel: $weight';
  }

  @override
  String get noExercisesYet => 'Brak ćwiczeń';

  @override
  String tapAddExerciseToStart(String button) {
    return 'Naciśnij „$button”, aby zacząć';
  }

  @override
  String get endWorkout => 'Zakończ trening';

  @override
  String exerciseNumber(int number) {
    return 'Ćwiczenie $number';
  }

  @override
  String weightWithUnit(String unit) {
    return 'Ciężar ($unit)';
  }

  @override
  String get startExercise => 'Rozpocznij ćwiczenie';

  @override
  String fixSetTitle(int number) {
    return 'Popraw serię $number';
  }

  @override
  String recordedReps(int reps) {
    String _temp0 = intl.Intl.pluralLogic(
      reps,
      locale: localeName,
      other: 'Zapisano: $reps powtórzenia',
      many: 'Zapisano: $reps powtórzeń',
      few: 'Zapisano: $reps powtórzenia',
      one: 'Zapisano: $reps powtórzenie',
    );
    return '$_temp0';
  }

  @override
  String get fix => 'Popraw';

  @override
  String get noteOptional => 'Notatka (opcjonalnie)';

  @override
  String get noteHint => 'Jak poszło? Co zmienić następnym razem?';

  @override
  String get note => 'Notatka';

  @override
  String get today => 'dzisiaj';

  @override
  String moreItems(int count) {
    return '+$count więcej...';
  }

  @override
  String repsProgress(int current, int previous) {
    return '$current / $previous powt.';
  }

  @override
  String get focusLegs => 'nogi';

  @override
  String get focusUpperBody => 'górna część ciała';

  @override
  String get focusCore => 'core';

  @override
  String get focusGlutes => 'pośladki';

  @override
  String get focusBack => 'plecy';

  @override
  String get focusChest => 'klatka piersiowa';

  @override
  String get focusShoulders => 'barki';

  @override
  String get focusArms => 'ramiona';

  @override
  String get focusCardio => 'cardio';

  @override
  String get injuryKnee => 'kolano';

  @override
  String get injuryLowerBack => 'dolny odcinek pleców';

  @override
  String get injuryShoulder => 'bark';

  @override
  String get injuryWrist => 'nadgarstek';

  @override
  String get injuryElbow => 'łokieć';

  @override
  String get injuryAnkle => 'kostka';

  @override
  String get injuryHip => 'biodro';

  @override
  String get injuryNeck => 'szyja';

  @override
  String get injuryHamstring => 'mięsień dwugłowy uda';

  @override
  String get injuryGroin => 'pachwina';

  @override
  String get hintWeightLb => 'np. 155';

  @override
  String worldRecordMatchingUnavailable(String error) {
    return 'Dopasowanie do rekordów świata niedostępne: $error';
  }

  @override
  String get myRecords => 'Moje rekordy';

  @override
  String get yourRank => 'Twoja ranga';

  @override
  String get worldRecordDataUnavailable =>
      'Dane rekordów świata niedostępne — ranga zaktualizuje się po załadowaniu.';

  @override
  String yourBest(String weight) {
    return 'Twój najlepszy: $weight';
  }

  @override
  String worldRecordFederation(String federation, String weight) {
    return 'Rekord świata ($federation): $weight';
  }

  @override
  String weightToNextRank(String weight, String rank) {
    return '+$weight do rangi $rank';
  }

  @override
  String get maxRankAchieved => 'Osiągnięto maksymalną rangę!';

  @override
  String get rankSystem => 'System rang';

  @override
  String get rankSystemDesc =>
      'Na podstawie % rekordu świata w Twojej kategorii wagowej';

  @override
  String rankPercentRange(String min, String max) {
    return '$min% – $max% rekordu świata';
  }

  @override
  String get last30Days => 'Ostatnie 30 dni';

  @override
  String get actualMax => 'Faktyczne maksimum';

  @override
  String oneRepOnDate(String date) {
    return '1 powt. · $date';
  }

  @override
  String get noOneRepSets => 'Brak serii na 1 powtórzenie';

  @override
  String get estimated1RM => 'Szacowane 1RM';

  @override
  String get noWorkoutsLast30Days => 'Brak treningów w ostatnich 30 dniach';

  @override
  String oneRmValue(String weight) {
    return '1RM: $weight';
  }

  @override
  String get noRecordsYet => 'Brak rekordów';

  @override
  String get completeWorkoutsForRecords =>
      'Ukończ treningi, aby śledzić swoje rekordy';

  @override
  String estimatedShort(String weight) {
    return 'szac. $weight';
  }

  @override
  String get yourWeightClass => 'Twoja kategoria wagowa';

  @override
  String get coefficientsDesc =>
      'Te współczynniki normalizują siłę względem masy ciała, aby porównanie było uczciwe';

  @override
  String get big3Total => 'Suma trójboju';

  @override
  String liftsOutOfThree(int count) {
    return '$count/3 bojów';
  }

  @override
  String get ratingBeginner => 'Początkujący';

  @override
  String get ratingIntermediate => 'Średniozaawansowany';

  @override
  String get ratingAdvanced => 'Zaawansowany';

  @override
  String get ratingElite => 'Elita';

  @override
  String get ratingWorldClass => 'Klasa światowa';

  @override
  String get liftSquat => 'Przysiad';

  @override
  String get liftBenchPress => 'Wyciskanie leżąc';

  @override
  String get liftDeadlift => 'Martwy ciąg';

  @override
  String get strengthCoefficient => 'Współczynnik siły';

  @override
  String get aboutStrengthCoefficient => 'O współczynniku siły';

  @override
  String get strengthCoefficientDesc =>
      'Współczynnik jest liczony na podstawie postępów we WSZYSTKICH ćwiczeniach. 100 = poziom wyjściowy (Twoje początkowe ciężary), 150 = o 50% silniejszy, 200 = 2 razy silniejszy. Pokazuje długoterminowy rozwój siły, a nie tylko ostatnie treningi.';

  @override
  String get strengthCoefficientProgress => 'Postęp współczynnika siły';

  @override
  String get currentWeight => 'Aktualna waga';

  @override
  String get startingWeight => 'Waga początkowa';

  @override
  String get change => 'Zmiana';

  @override
  String get averageWeight => 'Średnia waga';

  @override
  String get weightTrackingTip => 'Wskazówka dot. wagi';

  @override
  String weightTrackingTipDesc(String feature) {
    return 'Aby śledzić historię wagi, regularnie aktualizuj aktualną wagę w sekcji „$feature” w menu głównym.';
  }

  @override
  String get periodThisWeek => 'Ten tydzień';

  @override
  String get periodLast30Days => 'Ostatnie 30 dni';

  @override
  String get periodLast90Days => 'Ostatnie 90 dni';

  @override
  String get periodLast180Days => 'Ostatnie 180 dni';

  @override
  String get periodLastYear => 'Ostatni rok';

  @override
  String totalVolumeFor(String period) {
    return 'Całkowita objętość ($period)';
  }

  @override
  String get avgPerWeek => 'Śr./tydz.';

  @override
  String get weeklyVolume => 'Objętość tygodniowa';

  @override
  String get dailyVolume => 'Objętość dzienna';

  @override
  String get weightHistory => 'Historia wagi';

  @override
  String get workoutsPerWeek => 'Treningi/tydz.';

  @override
  String get totalWorkouts => 'Łącznie treningów';

  @override
  String get workoutFrequencyChart => 'Częstotliwość treningów (na tydzień)';

  @override
  String get completionRate => 'Wskaźnik ukończenia';

  @override
  String get setsCompleted => 'Ukończone serie';

  @override
  String get setsPlanned => 'Zaplanowane serie';

  @override
  String get workoutCompletionRate => 'Ukończenie treningów';

  @override
  String get maximumWeight => 'Maksymalny ciężar';

  @override
  String get maximumWeightProgress => 'Postęp maksymalnego ciężaru';

  @override
  String get volumeWeightReps => 'Objętość (ciężar × powtórzenia)';

  @override
  String get intensityPercent => 'Intensywność (%)';

  @override
  String get thousandSuffix => 'tys.';

  @override
  String get millionSuffix => 'mln';

  @override
  String get you => 'Ty';

  @override
  String get exerciseLabel => 'Ćwiczenie';

  @override
  String get challengeAccepted => 'Wyzwanie przyjęte!';

  @override
  String get challengeDeclined => 'Wyzwanie odrzucone';

  @override
  String get challengeEnded => 'Zakończone';

  @override
  String daysLeft(int count) {
    return 'zostało $count dni';
  }

  @override
  String hoursLeft(int count) {
    return 'zostało $count godz.';
  }

  @override
  String minutesLeft(int count) {
    return 'zostało $count min';
  }

  @override
  String workoutsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count treningi',
      many: '$count treningów',
      few: '$count treningi',
      one: '$count trening',
    );
    return '$_temp0';
  }

  @override
  String get challengeWorkoutsTitle => 'Wyzwanie treningowe';

  @override
  String get challengeWorkoutsDesc => 'Kto ukończy najwięcej treningów?';

  @override
  String get challengeWeightTitle => 'Wyzwanie na ciężar';

  @override
  String get challengeWeightDesc => 'Kto podniesie największy łączny ciężar?';

  @override
  String get challengeExerciseTitle => 'Wyzwanie w ćwiczeniu';

  @override
  String get challengeExerciseDesc =>
      'Kto podniesie najwięcej w wybranym ćwiczeniu?';

  @override
  String get challengeStreakTitle => 'Wyzwanie na serię';

  @override
  String get challengeStreakDesc => 'Kto utrzyma najdłuższą serię treningów?';

  @override
  String get challengeConsistencyTitle => 'Wyzwanie na regularność';

  @override
  String get challengeConsistencyDesc => 'Kto trenuje najwięcej dni z rzędu?';

  @override
  String get scopeGlobal => 'Świat';

  @override
  String get scopeMyLeague => 'Moja liga';

  @override
  String get scopeCountry => 'Kraj';

  @override
  String get scopeCity => 'Miasto';

  @override
  String get periodAllTime => 'Cały czas';

  @override
  String get periodThisMonth => 'Ten miesiąc';

  @override
  String get tabTotalWeight => 'Łączny ciężar';

  @override
  String get tabRecords => 'Rekordy';

  @override
  String get setCountryForRankings =>
      'Ustaw kraj w Profil → O mnie, aby zobaczyć ranking kraju';

  @override
  String get setCityForRankings =>
      'Ustaw miasto w Profil → O mnie, aby zobaczyć ranking miasta';

  @override
  String get addFriendsForLeague =>
      'Dodaj znajomych, aby zobaczyć ranking ligi';

  @override
  String get noDataYet => 'Brak danych';

  @override
  String get exerciseColon => 'Ćwiczenie:';

  @override
  String get selectAnExerciseShort => 'Wybierz ćwiczenie';

  @override
  String get noRecord => 'Brak rekordu';

  @override
  String errorWithMessage(String error) {
    return 'Błąd: $error';
  }

  @override
  String get matchPoor => 'Słabe dopasowanie';

  @override
  String get matchFair => 'Niezłe dopasowanie';

  @override
  String get matchModerate => 'Umiarkowane dopasowanie';

  @override
  String get matchGood => 'Dobre dopasowanie';

  @override
  String get matchGreat => 'Świetne dopasowanie';

  @override
  String get quickWorkoutDesc =>
      'Bez planu? Po prostu zacznij — dodawaj ćwiczenia w trakcie';

  @override
  String get noSavedWorkoutsYet => 'Brak zapisanych treningów';

  @override
  String get createInWorkshopOrQuick =>
      'Utwórz trening w Warsztacie lub rozpocznij szybki trening powyżej';

  @override
  String get recommendedForToday => 'Polecane na dziś';

  @override
  String get allWorkouts => 'Wszystkie treningi';

  @override
  String get preview => 'Podgląd';

  @override
  String get progressionRecommendationsTitle => 'Rekomendacje progresji';

  @override
  String get recommendedDeloadDesc =>
      'Ostatnie treningi były ciężkie. Zmniejsz obciążenie, aby się zregenerować.';

  @override
  String get current => 'Obecnie';

  @override
  String get suggested => 'Sugerowane';

  @override
  String get reasonForChange => 'Powód zmiany:';

  @override
  String get completedInRecentWorkouts => 'Ukończono w ostatnich treningach:';

  @override
  String get averageWeightColon => 'Średni ciężar:';

  @override
  String get averageRepsColon => 'Średnia liczba powtórzeń:';

  @override
  String get estimated1RMColon => 'Szacowane 1RM:';

  @override
  String get weightTrendColon => 'Trend ciężaru:';

  @override
  String trendRising(String delta) {
    return '↑ Rośnie ($delta)';
  }

  @override
  String trendFalling(String delta) {
    return '↓ Spada ($delta)';
  }

  @override
  String get trendStable => '→ Stabilnie';

  @override
  String get daysSinceLastSession => 'Dni od ostatniego treningu:';

  @override
  String get generateProgramFailed =>
      'Nie udało się wygenerować programu. Sprawdź klucz API lub połączenie z internetem.';

  @override
  String get bodyweightTraining => 'Trening z masą ciała';

  @override
  String get specializedTraining => 'Trening specjalistyczny';

  @override
  String get maxStrengthPrograms => 'Programy na maksymalną siłę';

  @override
  String get approve => 'Zatwierdź';

  @override
  String get aiEvaluation => 'Ocena AI';

  @override
  String get evalEmptySummary => 'Pusty trening';

  @override
  String get evalEmptyDetail => 'Dodaj ćwiczenia, aby otrzymać ocenę AI.';

  @override
  String get evalExcellentSummary => 'Świetny trening!';

  @override
  String evalExcellentDetail(int count) {
    return 'Dobra struktura, zrównoważone obciążenie grup mięśni ($count). Trafnie dobrana objętość.';
  }

  @override
  String get evalGoodSummary => 'Dobry trening.';

  @override
  String evalGoodDetailFocus(String group) {
    return 'Solidna struktura z naciskiem na: $group. Drobne poprawki poprawią balans.';
  }

  @override
  String get evalGoodDetail =>
      'Solidna struktura. Drobne poprawki poprawią balans.';

  @override
  String get evalAverageSummary => 'Przeciętny trening.';

  @override
  String get evalAverageDetailFew =>
      'Rozważ dodanie ćwiczeń dla lepszego bodźca.';

  @override
  String get evalAverageDetail => 'Można poprawić objętość lub balans mięśni.';

  @override
  String get evalWeakSummary => 'Wymaga poprawy.';

  @override
  String get evalWeakDetailLowVolume =>
      'Bardzo mała objętość — dodaj serii, aby bodziec był odczuwalny.';

  @override
  String get evalWeakDetailImbalanced =>
      'Mocno niezrównoważone obciążenie. Rozłóż ćwiczenia na więcej grup mięśni.';

  @override
  String get evalPoorSummary => 'Słaba struktura treningu.';

  @override
  String get evalPoorDetail =>
      'Skrajny brak balansu lub zbyt mała objętość. Przebuduj plan.';

  @override
  String daysShort(int count) {
    return '$count d';
  }

  @override
  String exerciseUpdatedName(String name) {
    return 'Zaktualizowano ćwiczenie: $name';
  }

  @override
  String exerciseAddedName(String name) {
    return 'Dodano ćwiczenie: $name';
  }

  @override
  String get typeWeightReps => 'Ciężar + powtórzenia';

  @override
  String get typeRepsOnly => 'Tylko powtórzenia';

  @override
  String get typeCardio => 'Cardio';

  @override
  String get editWorkout => 'Edytuj trening';

  @override
  String get draft => 'Szkic';

  @override
  String get noExercisesAddedYet => 'Nie dodano jeszcze ćwiczeń';

  @override
  String get tapPlusToAddExercises => 'Naciśnij +, aby dodać ćwiczenia';

  @override
  String minutesShort(int count) {
    return '$count min';
  }

  @override
  String alternativeN(int number, String name) {
    return 'Zamiennik $number: $name';
  }

  @override
  String get addAlternative => 'Dodaj zamiennik';

  @override
  String get completeWellnessForRecommendation =>
      'Wypełnij ankietę samopoczucia, aby otrzymać rekomendację';

  @override
  String wellnessAverage(String avg, String answers) {
    return 'Śr.: $avg — $answers';
  }

  @override
  String get todaysRecommendation => 'Rekomendacja na dziś';

  @override
  String exercisesWithCount(int count) {
    return 'Ćwiczenia ($count)';
  }

  @override
  String overallConfidence(String percent) {
    return 'Ogólna pewność: $percent%';
  }

  @override
  String get privateProfile => 'Profil prywatny';

  @override
  String privateProfileDesc(String name) {
    return '$name ma profil prywatny.\nWidoczne są tylko nazwa i awatar.';
  }

  @override
  String get rank => 'Ranga';

  @override
  String get totalVolume => 'Całkowita objętość';

  @override
  String tonnesShort(String value) {
    return '$value t';
  }

  @override
  String get compareStats => 'Porównaj statystyki';

  @override
  String challengeFriend(String name) {
    return 'Wyzwij: $name';
  }

  @override
  String challengeSentTo(String name) {
    return 'Wysłano wyzwanie: $name!';
  }

  @override
  String get statsComparison => 'Porównanie statystyk';

  @override
  String get currentStreak => 'Obecna seria';

  @override
  String get youInParens => '(Ty)';

  @override
  String aheadBy(String diff, String percent) {
    return 'Prowadzisz o $diff ($percent%)';
  }

  @override
  String behindBy(String diff, String percent) {
    return 'Tracisz $diff ($percent%)';
  }

  @override
  String get notAvailable => 'B/D';

  @override
  String unlockedOfTotal(int unlocked, int total) {
    return 'Odblokowano $unlocked z $total';
  }

  @override
  String get tabAll => 'Wszystkie';

  @override
  String get tabStrength => 'Siła';

  @override
  String get tabSocial => 'Społeczne';

  @override
  String get tabSpecial => 'Specjalne';

  @override
  String get noAchievementsInCategory => 'Brak osiągnięć w tej kategorii';

  @override
  String unlockedOn(String date) {
    return 'Odblokowano $date';
  }

  @override
  String get unlocked => 'Odblokowane';

  @override
  String get userNamePlaceholder => 'Nazwa użytkownika';

  @override
  String get selectWorkoutForAnalyticsHint =>
      'Wybierz trening, aby zobaczyć szczegółową analizę';

  @override
  String kcalValue(String value) {
    return '$value kcal';
  }

  @override
  String get nutritionGoalQuestion => 'Jaki jest Twój cel żywieniowy?';

  @override
  String get nutritionGoalDesc =>
      'Od tego zależą dzienne zapotrzebowanie kaloryczne i podział makroskładników.';

  @override
  String get confirmGoal => 'Potwierdź cel';

  @override
  String get enabled => 'Włączone';

  @override
  String get disabled => 'Wyłączone';

  @override
  String get choosePrimaryColor => 'Wybierz główny kolor aplikacji';

  @override
  String get exerciseType => 'Typ ćwiczenia';

  @override
  String get exerciseTypeDesc =>
      'Określa, jakie dane są zapisywane podczas treningu';

  @override
  String get typeWeightRepsDesc => 'Serie, powtórzenia i ciężar';

  @override
  String get typeRepsOnlyDesc => 'Serie i powtórzenia, bez ciężaru';

  @override
  String get typeCardioDesc => 'Tylko czas trwania';

  @override
  String get chooseTrainingDirection => 'Wybierz kierunek treningu';

  @override
  String get aiProgramGeneration => 'Generowanie programu przez AI';

  @override
  String get aiProgramGenerationDesc =>
      'AI dopasuje program do Twoich celów i historii treningów';

  @override
  String get selectDirection => 'Wybierz kierunek';

  @override
  String get directionFullBody => 'Całe ciało';

  @override
  String get directionFullBodyDesc =>
      'Zrównoważony rozwój wszystkich grup mięśni';

  @override
  String get directionPowerliftingDesc =>
      'Maksymalna siła: przysiad, wyciskanie, martwy ciąg';

  @override
  String get directionArmWrestlingDesc =>
      'Przedramiona, nadgarstki, chwyt i siła ciągu';

  @override
  String get directionStreetliftingDesc =>
      'Kalistenika z obciążeniem i umiejętności z masą ciała';

  @override
  String get testing => 'Sprawdzanie...';

  @override
  String get testKey => 'Sprawdź klucz';

  @override
  String get howToGetApiKey => 'Jak zdobyć darmowy klucz API';

  @override
  String get apiKeyStep1 =>
      'Wejdź na console.groq.com i zarejestruj się (za darmo)';

  @override
  String get apiKeyStep2 => 'Otwórz „API Keys” w menu po lewej';

  @override
  String get apiKeyStep3 => 'Kliknij „Create API Key” i nadaj nazwę';

  @override
  String get apiKeyStep4 => 'Skopiuj klucz i wklej go tutaj';

  @override
  String get apiKeyFreeTier =>
      'Darmowy limit w zupełności wystarcza do użytku osobistego.';

  @override
  String get readyToTrainColon => 'Gotowe do treningu:';

  @override
  String get chooseAWorkout => 'Wybierz trening:';

  @override
  String macroProteinShort(String grams) {
    return 'B: $grams g';
  }

  @override
  String macroCarbsShort(String grams) {
    return 'W: $grams g';
  }

  @override
  String macroFatShort(String grams) {
    return 'T: $grams g';
  }

  @override
  String waterAmount(String liters, String ml) {
    return '$liters l  ($ml ml)';
  }

  @override
  String confidencePercent(int percent) {
    return 'pewność $percent%';
  }

  @override
  String withWeight(String weight) {
    return ' z ciężarem $weight';
  }

  @override
  String topPercentOfAthletes(String percent) {
    return 'Top $percent% sportowców';
  }

  @override
  String get nice => 'Super!';

  @override
  String get rankWooden => 'Drewniana';

  @override
  String get rankStone => 'Kamienna';

  @override
  String get rankIron => 'Żelazna';

  @override
  String get rankBronze => 'Brązowa';

  @override
  String get rankSilver => 'Srebrna';

  @override
  String get rankGold => 'Złota';

  @override
  String get rankDiamond => 'Diamentowa';

  @override
  String get goalAggressiveFatLoss => 'Intensywna redukcja';

  @override
  String get goalFatLoss => 'Redukcja';

  @override
  String get goalMaintain => 'Utrzymanie wagi';

  @override
  String get goalLeanBulk => 'Czysta masa';

  @override
  String get goalBulk => 'Masa';

  @override
  String get goalAggressiveFatLossDesc =>
      'Duży deficyt dla szybkiej redukcji. -500 kcal/dzień.';

  @override
  String get goalFatLossDesc =>
      'Umiarkowany deficyt dla stałej redukcji. -300 kcal/dzień.';

  @override
  String get goalMaintainDesc =>
      'Jedz na poziomie zapotrzebowania, aby utrzymać wagę.';

  @override
  String get goalLeanBulkDesc =>
      'Mała nadwyżka dla przyrostu mięśni z minimum tłuszczu. +250 kcal/dzień.';

  @override
  String get goalBulkDesc =>
      'Znaczna nadwyżka dla maksymalnego wzrostu mięśni. +500 kcal/dzień.';

  @override
  String get mealBreakfast => 'Śniadanie';

  @override
  String get mealLunch => 'Obiad';

  @override
  String get mealDinner => 'Kolacja';

  @override
  String get mealAfternoonSnack => 'Podwieczorek';

  @override
  String get mealMidMorningSnack => 'Drugie śniadanie';

  @override
  String notifMealTitle(String meal) {
    return '🍽 Czas na: $meal';
  }

  @override
  String notifMealBody(String kcal, String protein) {
    return '$kcal kcal · $protein g białka';
  }

  @override
  String get notifMealChannel => 'Przypomnienia o posiłkach';

  @override
  String get notifWaterTitle => '💧 Czas napić się wody';

  @override
  String get notifWaterBody => 'Pij wodę — Twoje ciało Ci podziękuje!';

  @override
  String get notifWaterChannel => 'Przypomnienia o wodzie';

  @override
  String get recoveryReallyNeedTrain => 'Naprawdę czas trenować!';

  @override
  String get recoveryDefinitelyTime => 'Zdecydowanie czas trenować';

  @override
  String get recoveryTrainedToday => 'Trenowane dziś — odpoczynek';

  @override
  String recoveryProgress(int days, int optimal) {
    return 'Regeneracja ($days/$optimal dni)';
  }

  @override
  String get recoveryGoodTime => 'Dobry czas na trening';

  @override
  String recoveryLongTime(int days) {
    return 'Dawno nietrenowane ($days dni)';
  }

  @override
  String get standardProgression => 'Standardowa progresja';

  @override
  String get reasonDeloadRecommended =>
      'Zalecany tydzień odciążenia dla regeneracji';

  @override
  String get reasonRestTrainedYesterday =>
      'Dzień odpoczynku — trenowałeś wczoraj';

  @override
  String get reasonRestWellness =>
      'Dzień odpoczynku — samopoczucie wskazuje na potrzebę regeneracji';

  @override
  String get reasonRestOverall =>
      'Na podstawie ogólnego stanu zalecany odpoczynek';

  @override
  String get reasonHighReadiness =>
      'Wysoka gotowość — świetny dzień na trening';

  @override
  String get reasonGoodReadiness => 'Dobra gotowość do umiarkowanego treningu';

  @override
  String get reasonLightTraining => 'Dziś zalecany lekki trening';

  @override
  String reasonDaysSinceWorkout(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days dni od ostatniego treningu — dobra regeneracja',
      many: '$days dni od ostatniego treningu — dobra regeneracja',
      few: '$days dni od ostatniego treningu — dobra regeneracja',
      one: '$days dzień od ostatniego treningu — dobra regeneracja',
    );
    return '$_temp0';
  }

  @override
  String get reasonWellRecovered => 'Dobrze zregenerowany po ostatniej sesji';

  @override
  String get reasonOneDayRecovery =>
      'Jeden dzień regeneracji — intensywność dostosowana';

  @override
  String reasonReadyToTrain(String muscles) {
    return 'Gotowe do treningu: $muscles';
  }

  @override
  String reasonRequireRest(String muscles) {
    return 'Wymagają odpoczynku: $muscles';
  }

  @override
  String get reasonHighSoreness => 'Silne zakwasy — ciężary dostosowane';

  @override
  String get reasonLowEnergy => 'Mało energii — rozważ lżejszą intensywność';

  @override
  String get reasonGoodEnergy => 'Dobry poziom energii';

  @override
  String get progNoHistory => 'Brak historii — użyto parametrów programu';

  @override
  String get progNewExercise =>
      'Nowe ćwiczenie — parametry dopasowane do Twoich celów';

  @override
  String get progDeload => 'Tydzień odciążenia — 90% ostatniego ciężaru';

  @override
  String progExcellentReps(String reps) {
    return 'Świetny wynik — cel +$reps powt.';
  }

  @override
  String get progAddingSet => 'Dobry postęp — dodajemy serię';

  @override
  String get progMaintainReps =>
      'Wymagający trening — utrzymujemy powtórzenia z ostatniej sesji';

  @override
  String get progBodyweightMaintain =>
      'Ćwiczenie z masą ciała — utrzymujemy poziom';

  @override
  String get progWellnessReduced =>
      'Zmniejszone obciążenie — uwzględniono samopoczucie';

  @override
  String get progLimitedRecovery =>
      'Ograniczona regeneracja — utrzymujemy ostatni ciężar';

  @override
  String progTrendingUp(String delta) {
    return 'Trend wzrostowy — $delta na podstawie ostatniego miesiąca';
  }

  @override
  String get progLoadReduced =>
      'Obciążenie zmniejszone na podstawie ostatniego trendu';

  @override
  String get progStable => 'Stabilnie — utrzymujemy ostatni ciężar';

  @override
  String get progWellnessConsidered => ' (uwzględniono samopoczucie)';

  @override
  String get popupRankUpTitle => 'Awans!';

  @override
  String popupRankUpMessage(String rank) {
    return 'Osiągnięto rangę: $rank.';
  }

  @override
  String get popupGreatProgressTitle => 'Świetny postęp!';

  @override
  String get popupGreatProgressMessage => 'Twój ogólny wynik szybko rośnie.';

  @override
  String get popupNewRecordTitle => 'Nowy rekord osobisty!';

  @override
  String get popupFirstWorkoutTitle => 'Pierwszy trening ukończony!';

  @override
  String get popupFirstWorkoutMessage => 'Witaj na drodze do siły.';

  @override
  String get rankReasonConsistency => 'regularności treningów i osiągnięciach';

  @override
  String rankReasonLifts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count śledzonych bojach względem rekordów świata',
      many: '$count śledzonych bojach względem rekordów świata',
      few: '$count śledzonych bojach względem rekordów świata',
      one: '$count śledzonym boju względem rekordów świata',
    );
    return '$_temp0';
  }

  @override
  String rankReasonSummary(String basis, int workouts, int streak) {
    return 'Na podstawie danych o $basis; treningi: $workouts, seria: $streak dni.';
  }

  @override
  String get rankReasonNotEnough =>
      'Za mało historii treningów — ranga doprecyzuje się wraz z kolejnymi sesjami.';

  @override
  String get errMustBeLoggedInFriends => 'Zaloguj się, aby wysyłać zaproszenia';

  @override
  String get errCannotAddYourself => 'Nie możesz dodać siebie do znajomych';

  @override
  String get errNoUserWithEmail =>
      'Nie znaleziono użytkownika z tym adresem e-mail';

  @override
  String get errAlreadyFriends => 'Jesteście już znajomymi';

  @override
  String get errRequestAlreadySent => 'Zaproszenie zostało już wysłane';

  @override
  String get errSendRequestFailed =>
      'Nie udało się wysłać zaproszenia. Spróbuj ponownie.';

  @override
  String get errUserDataNotFound => 'Nie znaleziono danych użytkownika';

  @override
  String get errAcceptRequestFailed =>
      'Nie udało się przyjąć zaproszenia. Spróbuj ponownie.';

  @override
  String get errRejectRequestFailed =>
      'Nie udało się odrzucić zaproszenia. Spróbuj ponownie.';

  @override
  String get errRemoveFriendFailed =>
      'Nie udało się usunąć znajomego. Spróbuj ponownie.';

  @override
  String get errCancelRequestFailed =>
      'Nie udało się anulować zaproszenia. Spróbuj ponownie.';

  @override
  String get errCreateChallengeFailed =>
      'Nie udało się utworzyć wyzwania. Spróbuj ponownie.';

  @override
  String get errAcceptChallengeFailed => 'Nie udało się przyjąć wyzwania';

  @override
  String get errDeclineChallengeFailed => 'Nie udało się odrzucić wyzwania';

  @override
  String get errRegistrationFailed => 'Rejestracja nie powiodła się.';

  @override
  String get errWeakPassword => 'Hasło jest zbyt słabe.';

  @override
  String get errEmailInUse => 'Ten adres e-mail jest już używany.';

  @override
  String get errInvalidEmailAuth => 'Nieprawidłowy adres e-mail.';

  @override
  String get errSignInFailed => 'Logowanie nie powiodło się.';

  @override
  String get errUserNotFound =>
      'Nie znaleziono użytkownika o tym adresie e-mail.';

  @override
  String get errWrongPassword => 'Nieprawidłowe hasło.';

  @override
  String get errUserDisabled => 'To konto zostało zablokowane.';

  @override
  String minutesValue(int count) {
    return '$count min';
  }

  @override
  String get achFirstWorkoutTitle => 'Pierwsze kroki';

  @override
  String get achFirstWorkoutDesc => 'Ukończ pierwszy trening';

  @override
  String get achWorkout10Title => 'Dobry początek';

  @override
  String get achWorkout50Title => 'Zaangażowany';

  @override
  String get achWorkout100Title => 'Setka';

  @override
  String get achWorkout500Title => 'Legenda';

  @override
  String achCompleteWorkouts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ukończ $count treningi',
      many: 'Ukończ $count treningów',
      few: 'Ukończ $count treningi',
      one: 'Ukończ $count trening',
    );
    return '$_temp0';
  }

  @override
  String get achWeight1000Title => 'Lekka waga';

  @override
  String get achWeight10000Title => 'Ciężarowiec';

  @override
  String get achWeight100000Title => 'Żelazny wojownik';

  @override
  String achLiftTotal(String weight) {
    return 'Podnieś łącznie $weight';
  }

  @override
  String get achWilks300Title => 'Silny';

  @override
  String get achWilks400Title => 'Elitarna siła';

  @override
  String achReachWilks(int value) {
    return 'Osiągnij $value pkt Wilksa';
  }

  @override
  String get achStreak7Title => 'Wojownik tygodnia';

  @override
  String get achStreak30Title => 'Mistrz miesiąca';

  @override
  String get achStreak100Title => 'Niepowstrzymany';

  @override
  String achTrainDaysInRow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Trenuj $count dni z rzędu',
      many: 'Trenuj $count dni z rzędu',
      few: 'Trenuj $count dni z rzędu',
      one: 'Trenuj $count dzień z rzędu',
    );
    return '$_temp0';
  }

  @override
  String get achEarlyBirdTitle => 'Ranny ptaszek';

  @override
  String get achEarlyBirdDesc => 'Ukończ 10 treningów przed 8:00';

  @override
  String get achNightOwlTitle => 'Nocny marek';

  @override
  String get achNightOwlDesc => 'Ukończ 10 treningów po 20:00';

  @override
  String get achFirstFriendTitle => 'Towarzyski';

  @override
  String get achFirstFriendDesc => 'Dodaj pierwszego znajomego';

  @override
  String get achFriends10Title => 'Popularny';

  @override
  String get achFriends10Desc => 'Miej 10 znajomych';

  @override
  String get achChallengeWinnerTitle => 'Mistrz';

  @override
  String get achChallengeWinnerDesc => 'Wygraj pierwsze wyzwanie';

  @override
  String get achChallenge5Title => 'Rywal';

  @override
  String get achChallenge5Desc => 'Ukończ 5 wyzwań';

  @override
  String get achNewYearTitle => 'Nowy rok, nowy ja';

  @override
  String get achNewYearDesc => 'Trenuj w Nowy Rok';

  @override
  String get achBirthdayTitle => 'Urodzinowy progres';

  @override
  String get achBirthdayDesc => 'Trenuj w swoje urodziny';

  @override
  String get achPerfectWeekTitle => 'Idealny tydzień';

  @override
  String get achPerfectWeekDesc =>
      'Ukończ wszystkie zaplanowane treningi w tygodniu';

  @override
  String get measurements => 'Pomiary';

  @override
  String get measurementShoulders => 'Obręcz barkowa';

  @override
  String get measurementChest => 'Klatka piersiowa';

  @override
  String get measurementBicepsRight => 'Prawy biceps';

  @override
  String get measurementBicepsLeft => 'Lewy biceps';

  @override
  String get measurementForearmRight => 'Prawe przedramię';

  @override
  String get measurementForearmLeft => 'Lewe przedramię';

  @override
  String get measurementThighRight => 'Prawe udo';

  @override
  String get measurementThighLeft => 'Lewe udo';

  @override
  String get measurementCalfRight => 'Prawa łydka';

  @override
  String get measurementCalfLeft => 'Lewa łydka';

  @override
  String get measurementsHint =>
      'Dotknij pierścienia wokół ciała, aby wpisać obwód';

  @override
  String get measurementCircumference => 'Obwód';

  @override
  String measurementInvalid(String min, String max) {
    return 'Wpisz wartość od $min do $max';
  }

  @override
  String measurementUpdated(String date) {
    return 'Ostatnia aktualizacja: $date';
  }

  @override
  String get challengesSocial => 'Społeczne';

  @override
  String get challengesPersonal => 'Osobiste';

  @override
  String get challengeYourself => 'Rzuć wyzwanie sobie';

  @override
  String get challengeYourselfHint =>
      'Nie zaznaczaj nikogo, aby rzucić wyzwanie tylko sobie.';

  @override
  String get personalChallengesIntro =>
      'Wyzwania systemowe weryfikowane kamerą. Ustaw telefon tak, aby była widoczna cała sylwetka.';

  @override
  String get exercisePushUps => 'Pompki';

  @override
  String personalBest(int count) {
    return 'Rekord: $count';
  }

  @override
  String get personalChallengeDone => 'Zaliczone';

  @override
  String get startAttempt => 'Start';

  @override
  String get poseCameraTitle => 'Śledzenie sylwetki';

  @override
  String get poseSwitchCamera => 'Przełącz kamerę';

  @override
  String get poseStartRecording => 'Rozpocznij nagrywanie';

  @override
  String get poseStopRecording => 'Zatrzymaj nagrywanie';

  @override
  String get poseLoadingModel => 'Ładowanie modelu…';

  @override
  String get poseNoPerson => 'Odsuń się, aby cała sylwetka była w kadrze';

  @override
  String poseLandmarksVisible(int count) {
    return 'Punkty: $count/33';
  }

  @override
  String poseCameraError(String error) {
    return 'Błąd kamery: $error';
  }

  @override
  String get poseNoCamera => 'Brak dostępnej kamery';

  @override
  String get poseCameraPermissionDenied =>
      'Brak dostępu do kamery. Zezwól w ustawieniach systemu.';

  @override
  String get poseRepCounterSoon =>
      'Automatyczne liczenie powtórzeń już wkrótce';

  @override
  String poseTarget(int count) {
    return 'Cel: $count';
  }

  @override
  String get poseRecordingSaved => 'Nagranie zapisane';

  @override
  String get poseDeleteRecording => 'Usuń';

  @override
  String get poseKeepRecording => 'Zachowaj';
}
