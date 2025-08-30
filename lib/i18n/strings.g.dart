/// Generated file. Do not edit.
///
/// Original: lib/i18n
/// To regenerate, run: `dart run slang`
///
/// Locales: 2
/// Strings: 108 (54 per locale)
///
/// Built on 2025-08-30 at 20:09 UTC

// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.en;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale with BaseAppLocale<AppLocale, Translations> {
	en(languageCode: 'en', build: Translations.build),
	de(languageCode: 'de', build: _StringsDe.build);

	const AppLocale({required this.languageCode, this.scriptCode, this.countryCode, required this.build}); // ignore: unused_element

	@override final String languageCode;
	@override final String? scriptCode;
	@override final String? countryCode;
	@override final TranslationBuilder<AppLocale, Translations> build;

	/// Gets current instance managed by [LocaleSettings].
	Translations get translations => LocaleSettings.instance.translationMap[this]!;
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
/// Configurable via 'translate_var'.
///
/// Usage:
/// String a = t.someKey.anotherKey;
/// String b = t['someKey.anotherKey']; // Only for edge cases!
Translations get t => LocaleSettings.instance.currentTranslations;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
/// String b = t['someKey.anotherKey']; // Only for edge cases!
class TranslationProvider extends BaseTranslationProvider<AppLocale, Translations> {
	TranslationProvider({required super.child}) : super(settings: LocaleSettings.instance);

	static InheritedLocaleData<AppLocale, Translations> of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context);
}

/// Method B shorthand via [BuildContext] extension method.
/// Configurable via 'translate_var'.
///
/// Usage (e.g. in a widget's build method):
/// context.t.someKey.anotherKey
extension BuildContextTranslationsExtension on BuildContext {
	Translations get t => TranslationProvider.of(this).translations;
}

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseFlutterLocaleSettings<AppLocale, Translations> {
	LocaleSettings._() : super(utils: AppLocaleUtils.instance);

	static final instance = LocaleSettings._();

	// static aliases (checkout base methods for documentation)
	static AppLocale get currentLocale => instance.currentLocale;
	static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();
	static AppLocale setLocale(AppLocale locale, {bool? listenToDeviceLocale = false}) => instance.setLocale(locale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale setLocaleRaw(String rawLocale, {bool? listenToDeviceLocale = false}) => instance.setLocaleRaw(rawLocale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale useDeviceLocale() => instance.useDeviceLocale();
	@Deprecated('Use [AppLocaleUtils.supportedLocales]') static List<Locale> get supportedLocales => instance.supportedLocales;
	@Deprecated('Use [AppLocaleUtils.supportedLocalesRaw]') static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
	static void setPluralResolver({String? language, AppLocale? locale, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver}) => instance.setPluralResolver(
		language: language,
		locale: locale,
		cardinalResolver: cardinalResolver,
		ordinalResolver: ordinalResolver,
	);
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, Translations> {
	AppLocaleUtils._() : super(baseLocale: _baseLocale, locales: AppLocale.values);

	static final instance = AppLocaleUtils._();

	// static aliases (checkout base methods for documentation)
	static AppLocale parse(String rawLocale) => instance.parse(rawLocale);
	static AppLocale parseLocaleParts({required String languageCode, String? scriptCode, String? countryCode}) => instance.parseLocaleParts(languageCode: languageCode, scriptCode: scriptCode, countryCode: countryCode);
	static AppLocale findDeviceLocale() => instance.findDeviceLocale();
	static List<Locale> get supportedLocales => instance.supportedLocales;
	static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
}

// translations

// Path: <root>
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	// Translations
	late final _StringsAppEn app = _StringsAppEn._(_root);
	late final _StringsAuthEn auth = _StringsAuthEn._(_root);
	late final _StringsVoiceEn voice = _StringsVoiceEn._(_root);
	late final _StringsCommonEn common = _StringsCommonEn._(_root);
	late final _StringsErrorsEn errors = _StringsErrorsEn._(_root);
	late final _StringsLanguageEn language = _StringsLanguageEn._(_root);
}

// Path: app
class _StringsAppEn {
	_StringsAppEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Voice Pad';
	String get subtitle => 'Sign in to continue';
}

// Path: auth
class _StringsAuthEn {
	_StringsAuthEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get signIn => 'Sign In';
	String get signUp => 'Sign Up';
	String get createAccount => 'Create Account';
	String get fullName => 'Full Name';
	String get email => 'Email';
	String get password => 'Password';
	String get confirmPassword => 'Confirm Password';
	String get dontHaveAccount => 'Don\'t have an account? ';
	String get alreadyHaveAccount => 'Already have an account? ';
	String get or => 'or';
	String get loginSuccessful => 'Login successful!';
	String get accountCreated => 'Account created successfully!';
	late final _StringsAuthValidationEn validation = _StringsAuthValidationEn._(_root);
}

// Path: voice
class _StringsVoiceEn {
	_StringsVoiceEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Voice Pad';
	String get tapToRecord => 'Tap to record';
	String get listening => 'Listening...';
	String get processing => 'Processing...';
	String get recordingInProgress => 'Recording in progress...';
	String get convertingSpeech => 'Converting speech to text...';
	String get tapToStart => 'Tap to start recording';
	String get tryExample => 'Try saying: "Remind me to buy groceries at 6 PM"';
	String get notes => 'Notes';
	String get reminder => 'Reminder';
	String get textNote => 'Text Note';
	String get noNotes => 'No notes yet';
	String get noReminders => 'No reminder notes yet';
	String get createFirstNote => 'Tap the + button to create your first note';
	String get createFirstReminder => 'Tap the + button to create your first reminder';
}

// Path: common
class _StringsCommonEn {
	_StringsCommonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get save => 'Save';
	String get cancel => 'Cancel';
	String get delete => 'Delete';
	String get edit => 'Edit';
	String get close => 'Close';
	String get yes => 'Yes';
	String get no => 'No';
	String get ok => 'OK';
	String get error => 'Error';
	String get success => 'Success';
	String get loading => 'Loading...';
	String get retry => 'Retry';
}

// Path: errors
class _StringsErrorsEn {
	_StringsErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get general => 'Something went wrong. Please try again.';
	String get network => 'Network error. Please check your connection.';
	String get voiceProcessing => 'We could not process your voice, please try again';
}

// Path: language
class _StringsLanguageEn {
	_StringsLanguageEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get english => 'English';
	String get german => 'Deutsch';
	String get selectLanguage => 'Select Language';
}

// Path: auth.validation
class _StringsAuthValidationEn {
	_StringsAuthValidationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get enterName => 'Please enter your name';
	String get enterEmail => 'Please enter your email';
	String get validEmail => 'Please enter a valid email';
	String get enterPassword => 'Please enter your password';
	String get passwordLength => 'Password must be at least 6 characters';
	String get confirmPassword => 'Please confirm your password';
	String get passwordsMatch => 'Passwords do not match';
}

// Path: <root>
class _StringsDe implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsDe.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.de,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <de>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	@override late final _StringsDe _root = this; // ignore: unused_field

	// Translations
	@override late final _StringsAppDe app = _StringsAppDe._(_root);
	@override late final _StringsAuthDe auth = _StringsAuthDe._(_root);
	@override late final _StringsVoiceDe voice = _StringsVoiceDe._(_root);
	@override late final _StringsCommonDe common = _StringsCommonDe._(_root);
	@override late final _StringsErrorsDe errors = _StringsErrorsDe._(_root);
	@override late final _StringsLanguageDe language = _StringsLanguageDe._(_root);
}

// Path: app
class _StringsAppDe implements _StringsAppEn {
	_StringsAppDe._(this._root);

	@override final _StringsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Voice Pad';
	@override String get subtitle => 'Anmelden um fortzufahren';
}

// Path: auth
class _StringsAuthDe implements _StringsAuthEn {
	_StringsAuthDe._(this._root);

	@override final _StringsDe _root; // ignore: unused_field

	// Translations
	@override String get signIn => 'Anmelden';
	@override String get signUp => 'Registrieren';
	@override String get createAccount => 'Konto erstellen';
	@override String get fullName => 'Vollständiger Name';
	@override String get email => 'E-Mail';
	@override String get password => 'Passwort';
	@override String get confirmPassword => 'Passwort bestätigen';
	@override String get dontHaveAccount => 'Haben Sie noch kein Konto? ';
	@override String get alreadyHaveAccount => 'Haben Sie bereits ein Konto? ';
	@override String get or => 'oder';
	@override String get loginSuccessful => 'Anmeldung erfolgreich!';
	@override String get accountCreated => 'Konto erfolgreich erstellt!';
	@override late final _StringsAuthValidationDe validation = _StringsAuthValidationDe._(_root);
}

// Path: voice
class _StringsVoiceDe implements _StringsVoiceEn {
	_StringsVoiceDe._(this._root);

	@override final _StringsDe _root; // ignore: unused_field

	// Translations
	@override String get title => 'Voice Pad';
	@override String get tapToRecord => 'Zum Aufnehmen tippen';
	@override String get listening => 'Hört zu...';
	@override String get processing => 'Verarbeitung...';
	@override String get recordingInProgress => 'Aufnahme läuft...';
	@override String get convertingSpeech => 'Sprache zu Text konvertieren...';
	@override String get tapToStart => 'Zum Starten der Aufnahme tippen';
	@override String get tryExample => 'Versuchen Sie zu sagen: "Erinnere mich daran, um 18 Uhr Lebensmittel zu kaufen"';
	@override String get notes => 'Notizen';
	@override String get reminder => 'Erinnerung';
	@override String get textNote => 'Textnotiz';
	@override String get noNotes => 'Noch keine Notizen';
	@override String get noReminders => 'Noch keine Erinnerungsnotizen';
	@override String get createFirstNote => 'Tippen Sie auf die + Taste, um Ihre erste Notiz zu erstellen';
	@override String get createFirstReminder => 'Tippen Sie auf die + Taste, um Ihre erste Erinnerung zu erstellen';
}

// Path: common
class _StringsCommonDe implements _StringsCommonEn {
	_StringsCommonDe._(this._root);

	@override final _StringsDe _root; // ignore: unused_field

	// Translations
	@override String get save => 'Speichern';
	@override String get cancel => 'Abbrechen';
	@override String get delete => 'Löschen';
	@override String get edit => 'Bearbeiten';
	@override String get close => 'Schließen';
	@override String get yes => 'Ja';
	@override String get no => 'Nein';
	@override String get ok => 'OK';
	@override String get error => 'Fehler';
	@override String get success => 'Erfolg';
	@override String get loading => 'Lädt...';
	@override String get retry => 'Wiederholen';
}

// Path: errors
class _StringsErrorsDe implements _StringsErrorsEn {
	_StringsErrorsDe._(this._root);

	@override final _StringsDe _root; // ignore: unused_field

	// Translations
	@override String get general => 'Etwas ist schief gelaufen. Bitte versuchen Sie es erneut.';
	@override String get network => 'Netzwerkfehler. Bitte überprüfen Sie Ihre Verbindung.';
	@override String get voiceProcessing => 'Wir konnten Ihre Stimme nicht verarbeiten, bitte versuchen Sie es erneut';
}

// Path: language
class _StringsLanguageDe implements _StringsLanguageEn {
	_StringsLanguageDe._(this._root);

	@override final _StringsDe _root; // ignore: unused_field

	// Translations
	@override String get english => 'English';
	@override String get german => 'Deutsch';
	@override String get selectLanguage => 'Sprache auswählen';
}

// Path: auth.validation
class _StringsAuthValidationDe implements _StringsAuthValidationEn {
	_StringsAuthValidationDe._(this._root);

	@override final _StringsDe _root; // ignore: unused_field

	// Translations
	@override String get enterName => 'Bitte geben Sie Ihren Namen ein';
	@override String get enterEmail => 'Bitte geben Sie Ihre E-Mail ein';
	@override String get validEmail => 'Bitte geben Sie eine gültige E-Mail ein';
	@override String get enterPassword => 'Bitte geben Sie Ihr Passwort ein';
	@override String get passwordLength => 'Passwort muss mindestens 6 Zeichen lang sein';
	@override String get confirmPassword => 'Bitte bestätigen Sie Ihr Passwort';
	@override String get passwordsMatch => 'Passwörter stimmen nicht überein';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'app.title': return 'Voice Pad';
			case 'app.subtitle': return 'Sign in to continue';
			case 'auth.signIn': return 'Sign In';
			case 'auth.signUp': return 'Sign Up';
			case 'auth.createAccount': return 'Create Account';
			case 'auth.fullName': return 'Full Name';
			case 'auth.email': return 'Email';
			case 'auth.password': return 'Password';
			case 'auth.confirmPassword': return 'Confirm Password';
			case 'auth.dontHaveAccount': return 'Don\'t have an account? ';
			case 'auth.alreadyHaveAccount': return 'Already have an account? ';
			case 'auth.or': return 'or';
			case 'auth.loginSuccessful': return 'Login successful!';
			case 'auth.accountCreated': return 'Account created successfully!';
			case 'auth.validation.enterName': return 'Please enter your name';
			case 'auth.validation.enterEmail': return 'Please enter your email';
			case 'auth.validation.validEmail': return 'Please enter a valid email';
			case 'auth.validation.enterPassword': return 'Please enter your password';
			case 'auth.validation.passwordLength': return 'Password must be at least 6 characters';
			case 'auth.validation.confirmPassword': return 'Please confirm your password';
			case 'auth.validation.passwordsMatch': return 'Passwords do not match';
			case 'voice.title': return 'Voice Pad';
			case 'voice.tapToRecord': return 'Tap to record';
			case 'voice.listening': return 'Listening...';
			case 'voice.processing': return 'Processing...';
			case 'voice.recordingInProgress': return 'Recording in progress...';
			case 'voice.convertingSpeech': return 'Converting speech to text...';
			case 'voice.tapToStart': return 'Tap to start recording';
			case 'voice.tryExample': return 'Try saying: "Remind me to buy groceries at 6 PM"';
			case 'voice.notes': return 'Notes';
			case 'voice.reminder': return 'Reminder';
			case 'voice.textNote': return 'Text Note';
			case 'voice.noNotes': return 'No notes yet';
			case 'voice.noReminders': return 'No reminder notes yet';
			case 'voice.createFirstNote': return 'Tap the + button to create your first note';
			case 'voice.createFirstReminder': return 'Tap the + button to create your first reminder';
			case 'common.save': return 'Save';
			case 'common.cancel': return 'Cancel';
			case 'common.delete': return 'Delete';
			case 'common.edit': return 'Edit';
			case 'common.close': return 'Close';
			case 'common.yes': return 'Yes';
			case 'common.no': return 'No';
			case 'common.ok': return 'OK';
			case 'common.error': return 'Error';
			case 'common.success': return 'Success';
			case 'common.loading': return 'Loading...';
			case 'common.retry': return 'Retry';
			case 'errors.general': return 'Something went wrong. Please try again.';
			case 'errors.network': return 'Network error. Please check your connection.';
			case 'errors.voiceProcessing': return 'We could not process your voice, please try again';
			case 'language.english': return 'English';
			case 'language.german': return 'Deutsch';
			case 'language.selectLanguage': return 'Select Language';
			default: return null;
		}
	}
}

extension on _StringsDe {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'app.title': return 'Voice Pad';
			case 'app.subtitle': return 'Anmelden um fortzufahren';
			case 'auth.signIn': return 'Anmelden';
			case 'auth.signUp': return 'Registrieren';
			case 'auth.createAccount': return 'Konto erstellen';
			case 'auth.fullName': return 'Vollständiger Name';
			case 'auth.email': return 'E-Mail';
			case 'auth.password': return 'Passwort';
			case 'auth.confirmPassword': return 'Passwort bestätigen';
			case 'auth.dontHaveAccount': return 'Haben Sie noch kein Konto? ';
			case 'auth.alreadyHaveAccount': return 'Haben Sie bereits ein Konto? ';
			case 'auth.or': return 'oder';
			case 'auth.loginSuccessful': return 'Anmeldung erfolgreich!';
			case 'auth.accountCreated': return 'Konto erfolgreich erstellt!';
			case 'auth.validation.enterName': return 'Bitte geben Sie Ihren Namen ein';
			case 'auth.validation.enterEmail': return 'Bitte geben Sie Ihre E-Mail ein';
			case 'auth.validation.validEmail': return 'Bitte geben Sie eine gültige E-Mail ein';
			case 'auth.validation.enterPassword': return 'Bitte geben Sie Ihr Passwort ein';
			case 'auth.validation.passwordLength': return 'Passwort muss mindestens 6 Zeichen lang sein';
			case 'auth.validation.confirmPassword': return 'Bitte bestätigen Sie Ihr Passwort';
			case 'auth.validation.passwordsMatch': return 'Passwörter stimmen nicht überein';
			case 'voice.title': return 'Voice Pad';
			case 'voice.tapToRecord': return 'Zum Aufnehmen tippen';
			case 'voice.listening': return 'Hört zu...';
			case 'voice.processing': return 'Verarbeitung...';
			case 'voice.recordingInProgress': return 'Aufnahme läuft...';
			case 'voice.convertingSpeech': return 'Sprache zu Text konvertieren...';
			case 'voice.tapToStart': return 'Zum Starten der Aufnahme tippen';
			case 'voice.tryExample': return 'Versuchen Sie zu sagen: "Erinnere mich daran, um 18 Uhr Lebensmittel zu kaufen"';
			case 'voice.notes': return 'Notizen';
			case 'voice.reminder': return 'Erinnerung';
			case 'voice.textNote': return 'Textnotiz';
			case 'voice.noNotes': return 'Noch keine Notizen';
			case 'voice.noReminders': return 'Noch keine Erinnerungsnotizen';
			case 'voice.createFirstNote': return 'Tippen Sie auf die + Taste, um Ihre erste Notiz zu erstellen';
			case 'voice.createFirstReminder': return 'Tippen Sie auf die + Taste, um Ihre erste Erinnerung zu erstellen';
			case 'common.save': return 'Speichern';
			case 'common.cancel': return 'Abbrechen';
			case 'common.delete': return 'Löschen';
			case 'common.edit': return 'Bearbeiten';
			case 'common.close': return 'Schließen';
			case 'common.yes': return 'Ja';
			case 'common.no': return 'Nein';
			case 'common.ok': return 'OK';
			case 'common.error': return 'Fehler';
			case 'common.success': return 'Erfolg';
			case 'common.loading': return 'Lädt...';
			case 'common.retry': return 'Wiederholen';
			case 'errors.general': return 'Etwas ist schief gelaufen. Bitte versuchen Sie es erneut.';
			case 'errors.network': return 'Netzwerkfehler. Bitte überprüfen Sie Ihre Verbindung.';
			case 'errors.voiceProcessing': return 'Wir konnten Ihre Stimme nicht verarbeiten, bitte versuchen Sie es erneut';
			case 'language.english': return 'English';
			case 'language.german': return 'Deutsch';
			case 'language.selectLanguage': return 'Sprache auswählen';
			default: return null;
		}
	}
}
