import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static List<Locale> get supportedLocales {
    return const <Locale>[
      Locale('en'),
      Locale('fa'),
    ];
  }

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString(
      'lib/localization/l10n/app_${locale.languageCode}.arb',
    );
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Auth
  String get login => translate('login');
  String get register => translate('register');
  String get phoneNumber => translate('phoneNumber');
  String get verificationCode => translate('verificationCode');
  String get enterName => translate('enterName');
  String get allowNotifications => translate('allowNotifications');

  // Main Navigation
  String get alarms => translate('alarms');
  String get requests => translate('requests');
  String get notifications => translate('notifications');
  String get profile => translate('profile');

  // Requests
  String get sentRequests => translate('sentRequests');
  String get receivedRequests => translate('receivedRequests');
  String get createRequest => translate('createRequest');
  String get acceptRequest => translate('acceptRequest');
  String get rejectRequest => translate('rejectRequest');
  String get recordAlarm => translate('recordAlarm');
  String get shareRequestLink => translate('shareRequestLink');

  // Alarms
  String get setAlarm => translate('setAlarm');
  String get activeAlarms => translate('activeAlarms');
  String get inactiveAlarms => translate('inactiveAlarms');
  String get selectDateTime => translate('selectDateTime');
  String get selectRecording => translate('selectRecording');

  // General
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get share => translate('share');
  String get refresh => translate('refresh');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get retry => translate('retry');

  // Messages
  String get requestSentSuccessfully => translate('requestSentSuccessfully');
  String get requestAcceptedSuccessfully =>
      translate('requestAcceptedSuccessfully');
  String get requestRejectedSuccessfully =>
      translate('requestRejectedSuccessfully');
  String get alarmCreatedSuccessfully => translate('alarmCreatedSuccessfully');
  String get networkError => translate('networkError');
  String get serverError => translate('serverError');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fa'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
