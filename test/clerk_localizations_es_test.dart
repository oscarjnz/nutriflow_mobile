import 'package:clerk_flutter/generated/clerk_sdk_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutriflow_mobile/core/auth/clerk_localizations_es.dart';

/// The class extends the English one so a package upgrade that adds strings
/// cannot break the build. The cost of that choice is that a *missing*
/// override is also invisible - it silently serves English. These tests make
/// the strings the login screen actually shows visible to CI instead.
void main() {
  final es = ClerkSdkLocalizationsEs();
  final en = ClerkSdkLocalizationsEn();

  group('ClerkSdkLocalizationsEs', () {
    test('translates the copy on the first screen a new user sees', () {
      expect(es.signInTo('NutriFlow'), 'Inicia sesion en NutriFlow');
      expect(es.emailAddress, 'correo electronico');
      expect(es.password, 'Contrasena');
      expect(es.cont, 'Continuar');
      expect(es.signUp, 'Crear cuenta');
      expect(es.forgottenPassword, 'Olvidaste tu contrasena?');
    });

    test('keeps interpolated arguments in the translated string', () {
      expect(es.signUpTo('NutriFlow'), contains('NutriFlow'));
      expect(es.enterTheCodeSentTo('a@b.com'), contains('a@b.com'));
      expect(es.invalidEmailAddress('nope'), contains('nope'));
      expect(es.aLengthOfBetweenMINAndMAX(8, 64), allOf(contains('8'), contains('64')));
      expect(es.unknownError('boom'), contains('boom'));
    });

    test('leaves no English behind on the sign-in and account surfaces', () {
      // Every string reachable from ClerkAuthentication and ClerkUserButton,
      // which are the only two Clerk widgets this app mounts (see
      // features/auth/login_screen.dart and features/profile/profile_screen.dart).
      final translated = <String>[
        es.signIn,
        es.signUp,
        es.signOut,
        es.cont,
        es.cancel,
        es.back,
        es.ok,
        es.or,
        es.and,
        es.password,
        es.emailAddress,
        es.emailAddressConcise,
        es.phoneNumber,
        es.username,
        es.firstName,
        es.lastName,
        es.optional,
        es.requiredField,
        es.loading,
        es.resend,
        es.profile,
        es.addAccount,
        es.personalAccount,
        es.enterYourPassword,
        es.forgottenPassword,
        es.dontHaveAnAccount,
        es.alreadyHaveAnAccount,
        es.welcomeBackPleaseSignInToContinue,
        es.welcomePleaseFillInTheDetailsToGetStarted,
        es.pleaseEnterYourIdentifier,
        es.passwordMatchError,
        es.passwordMustBeSupplied,
        es.requiredFieldsAreMissing,
        es.signOutOfAllAccounts,
        es.selectAccount,
        es.twoStepVerification,
        es.verifyYourEmailAddress,
        es.termsOfService,
        es.privacyPolicy,
      ];
      final english = <String>[
        en.signIn,
        en.signUp,
        en.signOut,
        en.cont,
        en.cancel,
        en.back,
        en.ok,
        en.or,
        en.and,
        en.password,
        en.emailAddress,
        en.emailAddressConcise,
        en.phoneNumber,
        en.username,
        en.firstName,
        en.lastName,
        en.optional,
        en.requiredField,
        en.loading,
        en.resend,
        en.profile,
        en.addAccount,
        en.personalAccount,
        en.enterYourPassword,
        en.forgottenPassword,
        en.dontHaveAnAccount,
        en.alreadyHaveAnAccount,
        en.welcomeBackPleaseSignInToContinue,
        en.welcomePleaseFillInTheDetailsToGetStarted,
        en.pleaseEnterYourIdentifier,
        en.passwordMatchError,
        en.passwordMustBeSupplied,
        en.requiredFieldsAreMissing,
        en.signOutOfAllAccounts,
        en.selectAccount,
        en.twoStepVerification,
        en.verifyYourEmailAddress,
        en.termsOfService,
        en.privacyPolicy,
      ];

      for (var i = 0; i < translated.length; i++) {
        // '(opcional)' and 'Perfil' are the only plausible collisions, and
        // neither matches its English form, so any equality here is a real
        // missing override rather than a coincidence.
        expect(
          translated[i],
          isNot(english[i]),
          reason: 'string #$i still reads as English: "${english[i]}"',
        );
      }
    });

    test('carries no em dash, per the project-wide copy rule', () {
      final all = <String>[
        es.signInTo('NutriFlow'),
        es.welcomeBackPleaseSignInToContinue,
        es.welcomePleaseFillInTheDetailsToGetStarted,
        es.resetFailed,
        es.tooManyRetries,
        es.legalAcceptanceRequired,
        es.pleaseAddRequiredInformation,
      ];
      for (final text in all) {
        expect(text, isNot(contains('—')));
        expect(text, isNot(contains('–')));
      }
    });
  });
}
