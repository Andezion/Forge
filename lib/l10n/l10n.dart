import 'package:flutter/widgets.dart';
import 'package:dyplom/l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';

class L10n {
  static AppLocalizations _current = lookupAppLocalizations(const Locale('en'));

  static AppLocalizations get current => _current;

  static void setLanguage(AppLanguage language) {
    _current = lookupAppLocalizations(Locale(language.code));
  }
}
