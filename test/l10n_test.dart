import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:dyplom/l10n/generated/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String lang) =>
    jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _placeholders(String text) =>
    RegExp(r'\{(\w+)(?=[,}])').allMatches(text).map((m) => m[1]!).toSet();

void main() {
  group('ARB files', () {
    final en = _arb('en');
    final keys = en.keys.where((k) => !k.startsWith('@')).toSet();

    for (final lang in ['ru', 'pl']) {
      test('$lang has the same keys and placeholders as en', () {
        final other = _arb(lang);
        final otherKeys = other.keys.where((k) => !k.startsWith('@')).toSet();
        expect(otherKeys.difference(keys), isEmpty, reason: 'extra keys');
        expect(keys.difference(otherKeys), isEmpty, reason: 'missing keys');
        for (final key in keys) {
          expect(_placeholders(other[key] as String),
              _placeholders(en[key] as String),
              reason: '$lang.$key placeholders');
        }
      });
    }
  });

  group('plurals', () {
    final ru = lookupAppLocalizations(const Locale('ru'));
    final pl = lookupAppLocalizations(const Locale('pl'));
    final en = lookupAppLocalizations(const Locale('en'));

    test('russian one / few / many', () {
      expect(ru.exercisesCount(1), '1 упражнение');
      expect(ru.exercisesCount(3), '3 упражнения');
      expect(ru.exercisesCount(5), '5 упражнений');
      expect(ru.exercisesCount(21), '21 упражнение');
      expect(ru.setsCount(2), '2 подхода');
    });

    test('polish one / few / many', () {
      expect(pl.setsCount(1), '1 seria');
      expect(pl.setsCount(4), '4 serie');
      expect(pl.setsCount(5), '5 serii');
      expect(pl.setsCount(22), '22 serie');
    });

    test('english singular', () {
      expect(en.repsCount(1), '1 rep');
      expect(en.repsCount(8), '8 reps');
    });
  });
}
