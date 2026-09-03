# План дипломной работы (рабочая версия, RU)

Тема: Personalizowany, mobilny system do planowania treningów.
Целевой объём: 50+ страниц. Стиль/глубина — по образцу референсной работы коллеги.

1. Streszczenie i słowa kluczowe (PL + EN) — писать последним
2. Wstęp
3. Cel i zakres pracy
   3.1 Cel pracy (6 официальных целей)
   3.2 Zakres pracy (фактический стек + honestly про рост функционала)
4. Analiza wymagań i przegląd rozwiązań istniejących
   4.1 Zasada progresywnego przeciążenia i periodyzacji treningowej
   4.2 Problem samooceny gotowości treningowej
   4.3 Przegląd istniejących aplikacji (Strava, Hevy, Strong, JEFIT) — таблица сравнения
   4.4 Wnioski z analizy / gap-анализ
5. Technologie i architektura systemu
   5.1 Stos technologiczny i uzasadnienie wyboru (честно про эволюцию от Node/Express/PostgreSQL/Riverpod к Firebase/Provider)
   5.2 Architektura systemu (диаграмма client-server, слои models/services/screens/widgets)
   5.3 Model danych (Firestore + SharedPreferences сущности)
   5.4 Bezpieczeństwo i prywatność danych
6. Projekt i implementacja głównych modułów funkcjonalnych (по 6 целям брифа)
   6.1 Interfejs planowania i śledzenia treningów (cel 1)
   6.2 Adaptacyjny system doboru obciążenia (cel 2) — главная техническая глава: progression_service.dart
   6.3 Gotowe programy i kreator własnych planów (cel 3)
   6.4 System monitorowania stanu zdrowia (cel 4) — wellness + muscle_recovery_tracker + workout_recommendation_service
   6.5 Śledzenie postępów: wykresy (cel 5) — formulas.html + fl_chart
   6.6 Funkcja "Znajomi" (cel 6)
7. Funkcjonalności wykraczające poza podstawowy zakres pracy
   7.1 Generowanie planów z AI (Groq LLM)
   7.2 System rankingowy i grywalizacja (ranks/achievements/challenges)
   7.3 Tablica liderów i rekordy IPF (leaderboard_service, world_records_service, Cloud Function)
   7.4 Moduł żywieniowy
   7.5 Lokalizacja (EN/PL/RU) i onboarding
8. Metodyka walidacji systemu
   8.1 Grupa testowa — 5 osób (weteran/mistrz świata 40 lat stażu, aktualny mistrz świata, 2 początkujący, autor)
   8.2 Protokół testów — 6 miesięcy, grudzień–maj
   8.3 Testy funkcjonalne wewnętrzne
   8.4 Ankieta użyteczności
9. Wyniki badań i dyskusja
   9.1 Wyniki testów funkcjonalnych
   9.2 Wyniki ankiety / opinie grupy testowej
   9.3 Analiza trafności algorytmu adaptacyjnego na rzeczywistych danych (porównanie z decyzjami eksperta)
   9.4 Analiza porównawcza z istniejącymi aplikacjami
   9.5 Ograniczenia badania
10. Podsumowanie i kierunki dalszego rozwoju
11. Bibliografia / Spis rysunków / Spis tabel

## Статус
- [x] План согласован (2026-08-31)
- [x] 1. Streszczenie — предварительный черновик (01_streszczenie.md), ОДНО место ждёт данных из гл. 9
- [x] 2. Wstęp — черновик готов (02_wstep.md), правки внесены (в т.ч. уточнение про Hevy Trainer/JEFIT NSPI)
- [x] 3. Cel i zakres pracy — черновик готов (03_cel_i_zakres.md)
- [x] 4. Analiza wymagań — черновик готов (04_analiza_wymagan.md), таблица 4.3 на реальном веб-поиске
- [x] 5. Technologie i architektura — черновик готов (05_technologie_architektura.md)
- [x] 6. Moduły funkcjonalne — черновик готов (06_moduly_funkcjonalne.md), самая большая глава
- [x] 7. Funkcjonalności dodatkowe — черновик готов (07_funkcje_dodatkowe.md)
- [x] 8. Metodyka walidacji — черновик готов (08_metodyka_walidacji.md), много [TODO] под реальные данные протокола
- [x] 9. Wyniki i dyskusja — ТОЛЬКО СКЕЛЕТ (09_wyniki_dyskusja.md), реальные результаты не выдуманы принципиально
- [x] 10. Podsumowanie — черновик готов (10_podsumowanie.md), один абзац ждёт гл. 9
- [x] 11. Bibliografia/Spisy — черновик-чек-лист (11_bibliografia_spisy.md)

Все 11 частей есть в папке как файлы 01–11. Первый полный проход завершён 2026-08-31 — дальше идёт этап правок и, главное, наполнение главы 9 реальными данными за 6 месяцев теста.

## Открытые вопросы / чего не хватает (собрано по ходу первого прохода)
1. Гл. 8.1 — точный тренировочный стаж участников 3 и 4 (новички) и участника 2 (действующий чемпион).
2. Гл. 8.2 — точный протокол: периодичность контрольных точек, что именно логировалось помимо самого факта использования.
3. Гл. 8.4 — использовалась ли формализованная анкета (SUS или своя) или свободное интервью.
4. Гл. 9 целиком — реальные результаты: данные функциональных тестов (`flutter test` живой прогон), ответы анкеты/цитаты участников (особенно чемпионов — раздел 9.3, самая ценная часть работы), сравнение с аналогами по опыту использования, а не только по фичам.
5. Библиография — реальные источники по progresywne przeciążenie, RPE, самооценке готовности (см. `11_bibliografia_spisy.md` — что уже проверено веб-поиском, а что нужно подобрать самому).
6. Иллюстрации/скриншоты/диаграммы — чек-лист в `11_bibliografia_spisy.md`.
