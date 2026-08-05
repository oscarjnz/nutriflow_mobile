// ignore_for_file: public_member_api_docs

import 'package:clerk_flutter/generated/clerk_sdk_localizations_en.dart';

/// Spanish copy for Clerk's own sign-in, sign-up and account widgets.
///
/// The package ships English only, so without this the first screen of the
/// app - the one every new user sees before anything else - reads "Sign in to
/// NutriFlow" while the rest of NutriFlow is in Spanish (CLAUDE.md section 5:
/// UI text in Spanish, code in English).
///
/// Extends the English implementation rather than the abstract
/// [ClerkSdkLocalizations] on purpose: clerk_flutter is a beta package, and if
/// a release adds new strings this keeps compiling and shows those few in
/// English, instead of breaking the build over copy for a flow that may not
/// even be reachable here.
///
/// Wording notes, since they are choices and not the only possible reading:
/// - Formal "tu"/"tus" throughout, matching the rest of the app's copy.
/// - The bare field labels (`emailAddress`, `password`, ...) stay lowercase
///   because Clerk composes them into sentences through `ClerkSdkGrammar`,
///   which capitalizes the first word itself.
/// - Product terms Clerk itself does not translate on its dashboard
///   (passkey, SSO, slug) are kept, since a user who has one recognizes the
///   English word and not a coined Spanish one.
class ClerkSdkLocalizationsEs extends ClerkSdkLocalizationsEn {
  ClerkSdkLocalizationsEs() : super('es');

  @override
  String aLengthOfBetweenMINAndMAX(int min, int max) =>
      'entre $min y $max caracteres';

  @override
  String aLengthOfMINOrGreater(int min) => '$min caracteres o mas';

  @override
  String get aLowercaseLetter => 'una letra MINUSCULA';

  @override
  String get aNumber => 'un NUMERO';

  @override
  String aSpecialCharacter(String chars) => 'un CARACTER ESPECIAL ($chars)';

  @override
  String get abandoned => 'abandonada';

  @override
  String get acceptTerms => 'Acepto los Terminos del servicio y la Politica de privacidad';

  @override
  String get active => 'activa';

  @override
  String get addAccount => 'Agregar cuenta';

  @override
  String get addDomain => 'Agregar dominio';

  @override
  String get addEmailAddress => 'Agregar correo electronico';

  @override
  String get addPasskey => 'Agregar una passkey';

  @override
  String get addPhoneNumber => 'Agregar numero de telefono';

  @override
  String get alreadyHaveAnAccount => 'Ya tienes una cuenta?';

  @override
  String get anUppercaseLetter => 'una letra MAYUSCULA';

  @override
  String get and => 'y';

  @override
  String get areYouSure => 'Estas seguro?';

  @override
  String authenticationServiceError(String arg) =>
      'Hubo un error en el servicio de autenticacion: $arg';

  @override
  String get authenticatorApp => 'app de autenticacion';

  @override
  String get automaticInvitation => 'Invitacion automatica';

  @override
  String get automaticSuggestion => 'Sugerencia automatica';

  @override
  String get back => 'Volver';

  @override
  String get backupCode => 'codigo de respaldo';

  @override
  String get cancel => 'Cancelar';

  @override
  String get cannotDeleteSelf => 'No tienes autorizacion para eliminar tu propio usuario';

  @override
  String clickOnTheLinkThatsBeenSentTo(String identifier) =>
      'Abre el enlace que enviamos a $identifier y luego vuelve aqui';

  @override
  String get clickOnTheLinkThatsBeenSentToYou =>
      'Abre el enlace que te enviamos y luego vuelve aqui';

  @override
  String get complete => 'completa';

  @override
  String get connectAccount => 'Conectar cuenta';

  @override
  String get connectedAccounts => 'Cuentas conectadas';

  @override
  String get cont => 'Continuar';

  @override
  String get createOrganization => 'Crear organizacion';

  @override
  String get created => 'Creada';

  @override
  String get developmentMode => 'Modo de desarrollo';

  @override
  String get didntReceiveCode => 'No recibiste el codigo?';

  @override
  String get domainName => 'Nombre del dominio';

  @override
  String get dontHaveAnAccount => 'No tienes una cuenta?';

  @override
  String get edit => 'editar';

  @override
  String get emailAddress => 'correo electronico';

  @override
  String get emailAddressConcise => 'correo';

  @override
  String get emailAddresses => 'Correos electronicos';

  @override
  String get enrollment => 'Inscripcion';

  @override
  String get enrollmentMode => 'Modo de inscripcion:';

  @override
  String get enterOneOfYourBackupCodes => 'Ingresa uno de tus codigos de respaldo';

  @override
  String get enterTheCodeFromYourAuthenticatorApp =>
      'Ingresa el codigo generado por tu app de autenticacion';

  @override
  String enterTheCodeSentTo(String identifier) => 'Ingresa el codigo que enviamos a $identifier';

  @override
  String get enterTheCodeSentToYou => 'Ingresa el codigo que te enviamos';

  @override
  String get enterTheCodeSentToYouByEmail =>
      'Ingresa el codigo que te enviamos por correo electronico';

  @override
  String get enterTheCodeSentToYouByTextMessage =>
      'Ingresa el codigo que te enviamos por mensaje de texto';

  @override
  String get enterYourOrganizationDetailsToContinue =>
      'Ingresa los datos de tu organizacion para continuar';

  @override
  String get enterYourPassword => 'Ingresa tu contrasena';

  @override
  String get expired => 'vencida';

  @override
  String externalError(String arg) => '$arg (ERROR EXTERNO)';

  @override
  String get failed => 'fallida';

  @override
  String get firstName => 'nombre';

  @override
  String get forgottenPassword => 'Olvidaste tu contrasena?';

  @override
  String get generalDetails => 'Datos generales';

  @override
  String invalidEmailAddress(String address) => 'Correo electronico invalido: $address';

  @override
  String invalidPhoneNumber(String number) => 'Numero de telefono invalido: $number';

  @override
  String get join => 'UNIRSE';

  @override
  String jwtPoorlyFormatted(String arg) => 'JWT mal formado: $arg';

  @override
  String get lastName => 'apellido';

  @override
  String get lastUsed => 'Ultimo uso';

  @override
  String get leave => 'Salir';

  @override
  String leaveOrg(String organization) => 'Salir de $organization';

  @override
  String get leaveOrganization => 'Salir de la organizacion';

  @override
  String get legalAcceptanceRequired =>
      'Debes aceptar los terminos legales para continuar con el registro';

  @override
  String get loading => 'Cargando...';

  @override
  String get logo => 'Logo';

  /// Spanish writes the day-month-year date with "de" between the parts.
  @override
  String get longDateFormat => "d 'de' MMMM 'de' y, 'h:mm a";

  @override
  String get manualInvitation => 'Invitacion manual';

  @override
  String get missingRequirements => 'requisitos faltantes';

  @override
  String get myOrganization => 'Mi organizacion';

  @override
  String get name => 'Nombre';

  @override
  String get needsFirstFactor => 'requiere primer factor';

  @override
  String get needsIdentifier => 'requiere identificador';

  @override
  String get needsSecondFactor => 'requiere segundo factor';

  @override
  String get newPassword => 'Contrasena nueva';

  @override
  String get newPasswordConfirmation => 'Confirma la contrasena nueva';

  @override
  String noAssociatedCodeRetrievalMethod(String arg) =>
      'No encontramos un metodo para obtener el codigo asociado a $arg';

  @override
  String noAssociatedStrategy(String arg) => 'No hay una estrategia asociada a $arg';

  @override
  String get noInitialCodeHasBeenSetUpToResend =>
      'No hay un codigo inicial que se pueda reenviar';

  @override
  String noSessionFoundForUser(String arg) =>
      'No se encontro una sesion para el usuario $arg';

  @override
  String get noSessionTokenRetrieved => 'No se obtuvo el token de sesion';

  @override
  String noStageForStatus(String arg) => 'No hay una etapa para el estado $arg';

  @override
  String noSuchFirstFactorStrategy(String arg) =>
      'La estrategia $arg no es compatible como primer factor';

  @override
  String noSuchSecondFactorStrategy(String arg) =>
      'La estrategia $arg no es compatible como segundo factor';

  @override
  String noUserAttributeForField(String arg) =>
      'No se encontro un atributo de usuario para el campo $arg';

  @override
  String get ok => 'Aceptar';

  @override
  String get optional => '(opcional)';

  @override
  String get or => 'o';

  @override
  String get organizationProfile => 'Perfil de la organizacion';

  @override
  String get organizations => 'Organizaciones';

  @override
  String get passkey => 'passkey';

  @override
  String get passkeys => 'Passkeys';

  @override
  String get password => 'Contrasena';

  @override
  String get passwordConfirmation => 'confirma la contrasena';

  @override
  String get passwordMatchError => 'La contrasena y su confirmacion deben coincidir';

  @override
  String get passwordMustBeSupplied => 'Debes ingresar una contrasena';

  @override
  String get passwordRequires => 'La contrasena necesita:';

  @override
  String get pending => 'pendiente';

  @override
  String get personalAccount => 'Cuenta personal';

  @override
  String get phoneNumber => 'numero de telefono';

  @override
  String get phoneNumberConcise => 'telefono';

  @override
  String get phoneNumbers => 'Numeros de telefono';

  @override
  String get pleaseAddRequiredInformation =>
      'Parece que falta algo. Completa la informacion requerida';

  @override
  String get pleaseChooseAnAccountToConnect => 'Elige una cuenta para conectar';

  @override
  String get pleaseEnterYourIdentifier => 'Ingresa tu identificador';

  @override
  String get primary => 'PRINCIPAL';

  @override
  String get privacyPolicy => 'Politica de privacidad';

  @override
  String get profile => 'Perfil';

  @override
  String get profileDetails => 'Datos del perfil';

  @override
  String get recommendSize => 'Tamano recomendado 1:1, hasta 5MB.';

  @override
  String get requiredField => '(obligatorio)';

  @override
  String get requiredFieldsAreMissing => 'Faltan campos obligatorios';

  @override
  String get resend => 'Reenviar';

  @override
  String get resetFailed =>
      'No se pudo restablecer la contrasena. Te enviamos un codigo nuevo.';

  @override
  String get resetPassword => 'Restablecer contrasena e iniciar sesion';

  @override
  String get selectAccount => 'Elige la cuenta con la que quieres continuar';

  @override
  String get sendMeTheCode => 'Enviame el codigo de restablecimiento';

  @override
  String serverErrorResponse(String arg) => '$arg (ERROR RECIBIDO DEL SERVIDOR)';

  @override
  String get setUpYourOrganization => 'Configura tu organizacion';

  @override
  String get signIn => 'Iniciar sesion';

  @override
  String get signInByCodeSentToYourEmail => 'Enviar codigo a tu correo';

  @override
  String signInByEmailCode(String arg) => 'Enviar codigo por correo a $arg';

  @override
  String signInByEmailLink(String arg) => 'Enviar enlace por correo a $arg';

  @override
  String get signInByEnteringOneOfYourBackupCodes => 'Usar un codigo de respaldo';

  @override
  String get signInByLinkSentToYourEmail => 'Enviar enlace a tu correo';

  @override
  String signInBySMSCode(String arg) => 'Enviar codigo por SMS a $arg';

  @override
  String get signInBySMSCodeToYourPhone => 'Enviar codigo a tu telefono';

  @override
  String signInTo(String name) => 'Inicia sesion en $name';

  @override
  String get signInUsingEnterpriseSSO => 'Iniciar sesion con SSO empresarial';

  @override
  String get signInUsingYourAuthenticatorApp => 'Usar tu app de autenticacion';

  @override
  String get signInWithOneOfYourBackupCodes => 'Usar uno de tus codigos de respaldo';

  @override
  String get signOut => 'Cerrar sesion';

  @override
  String signOutIdentifier(String identifier) => 'Cerrar la sesion de $identifier';

  @override
  String get signOutOfAllAccounts => 'Cerrar sesion en todas las cuentas';

  @override
  String get signUp => 'Crear cuenta';

  @override
  String signUpTo(String name) => 'Crea tu cuenta en $name';

  @override
  String get slug => 'Slug';

  @override
  String get slugUrl => 'URL del slug';

  @override
  String get switchTo => 'Cambiar a';

  @override
  String get termsOfService => 'Terminos del servicio';

  @override
  String get tooManyRetries =>
      'El servidor esta ocupado. Intenta de nuevo en un momento.';

  @override
  String get transferable => 'transferible';

  @override
  String get twoStepVerification => 'Verificacion en dos pasos';

  @override
  String typeTypeInvalid(String type) => "El tipo '$type' no es valido";

  @override
  String unknownError(String arg) => 'Ocurrio un error desconocido: $arg';

  @override
  String unsupportedPasswordResetStrategy(String arg) =>
      'Estrategia de restablecimiento de contrasena no compatible: $arg';

  @override
  String get unverified => 'sin verificar';

  @override
  String get usePasskeyInstead => 'Usar una passkey';

  @override
  String get username => 'nombre de usuario';

  @override
  String get verificationEmailAddress => 'Verificacion del correo electronico';

  @override
  String get verificationPhoneNumber => 'Verificacion del numero de telefono';

  @override
  String get verified => 'verificada';

  @override
  String get verifiedDomains => 'Dominios verificados';

  @override
  String get verifyThisDevice => 'Verificar este dispositivo';

  @override
  String get verifyYourEmailAddress => 'Verifica tu correo electronico';

  @override
  String get verifyYourPhoneNumber => 'Verifica tu numero de telefono';

  @override
  String get viaAutomaticInvitation => 'por invitacion automatica';

  @override
  String get viaAutomaticSuggestion => 'por sugerencia automatica';

  @override
  String get viaManualInvitation => 'por invitacion manual';

  @override
  String get web3Wallet => 'billetera web3';

  @override
  String get welcomeBackPleaseSignInToContinue =>
      'Que bueno verte de nuevo. Inicia sesion para continuar';

  @override
  String get welcomePleaseFillInTheDetailsToGetStarted =>
      'Bienvenido. Completa tus datos para empezar';
}
