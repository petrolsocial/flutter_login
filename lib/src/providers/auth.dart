import 'package:flutter/material.dart';
import 'package:flutter_login/src/models/phone_login_data.dart';

import '../../flutter_login.dart';

enum AuthMode { signup, login }

enum AuthType { provider, userPassword }

/// The callback triggered after login
/// The result is an error message, callback successes if message is null
typedef LoginCallback = Future<String?>? Function(LoginData);

/// The callback triggered after phone login
/// The result is an error message, callback successes if message is null
typedef PhoneLoginCallback = Future<String?>? Function(PhoneLoginData);

/// The callback triggered after signup
/// The result is an error message, callback successes if message is null
typedef SignupCallback = Future<String?>? Function(SignupData);

/// The additional fields are provided as an `HashMap<String, String>`
/// The result is an error message, callback successes if message is null
typedef AdditionalFieldsCallback = Future<String?>? Function(
    Map<String, String>);

/// If the callback returns true, the additional data card is shown
typedef ProviderNeedsSignUpCallback = Future<bool> Function();

/// The result is an error message, callback successes if message is null
typedef ProviderAuthCallback = Future<String?>? Function();

/// The result is an error message, callback successes if message is null
typedef RecoverCallback = Future<String?>? Function(String);

/// The result is an error message, callback successes if message is null
typedef ConfirmSignupCallback = Future<String?>? Function(String, LoginData);

/// The result is an error message, callback successes if message is null
typedef ConfirmRecoverCallback = Future<String?>? Function(String, LoginData);

class Auth with ChangeNotifier {
  Auth(
      this.phoneLoginOtpSentNotifier, this.phoneLoginVerificationStatusNotifier,
      {this.loginProviders = const [],
      this.onLogin,
      this.onSignup,
      this.onPhoneLogin,
      this.onPhoneLoginOtp,
      this.onRecoverPassword,
      this.onConfirmRecover,
      this.onConfirmSignup,
      this.onResendCode,
      String email = '',
      String password = '',
      String confirmPassword = '',
      AuthMode initialAuthMode = AuthMode.login,
      this.termsOfService = const []})
      : _email = email,
        _password = password,
        _confirmPassword = confirmPassword,
        _mode = initialAuthMode;

  final LoginCallback? onLogin;
  final SignupCallback? onSignup;
  final PhoneLoginCallback? onPhoneLogin;
  final PhoneLoginCallback? onPhoneLoginOtp;
  final RecoverCallback? onRecoverPassword;
  final List<LoginProvider> loginProviders;
  final ConfirmRecoverCallback? onConfirmRecover;
  final ConfirmSignupCallback? onConfirmSignup;
  final SignupCallback? onResendCode;
  final List<TermOfService> termsOfService;
  final ValueNotifier<bool>? phoneLoginOtpSentNotifier;
  final ValueNotifier<String?>? phoneLoginVerificationStatusNotifier;

  AuthType _authType = AuthType.userPassword;
  bool isAnonymous = false;

  /// Used to decide if the login/signup comes from a provider or normal login
  AuthType get authType => _authType;
  set authType(AuthType authType) {
    _authType = authType;
    notifyListeners();
  }

  AuthMode _mode = AuthMode.login;
  AuthMode get mode => _mode;
  set mode(AuthMode value) {
    _mode = value;
    notifyListeners();
  }

  bool get isLogin => _mode == AuthMode.login;
  bool get isSignup => _mode == AuthMode.signup;
  int currentCardIndex = 0;

  AuthMode opposite() {
    return _mode == AuthMode.login ? AuthMode.signup : AuthMode.login;
  }

  AuthMode switchAuth() {
    if (mode == AuthMode.login) {
      mode = AuthMode.signup;
    } else if (mode == AuthMode.signup) {
      mode = AuthMode.login;
    }
    return mode;
  }

  String _email = '';
  String get email => _email;
  set email(String email) {
    _email = email;
    notifyListeners();
  }

  String _password = '';
  String get password => _password;
  set password(String password) {
    _password = password;
    notifyListeners();
  }

  String _phoneNumber = '';
  String get phoneNumber => _phoneNumber;
  set phoneNumber(String phoneNumber) {
    _phoneNumber = phoneNumber;
    notifyListeners();
  }

  String _confirmPassword = '';
  String get confirmPassword => _confirmPassword;
  set confirmPassword(String confirmPassword) {
    _confirmPassword = confirmPassword;
    notifyListeners();
  }

  Map<String, String>? _additionalSignupData;
  Map<String, String>? get additionalSignupData => _additionalSignupData;
  set additionalSignupData(Map<String, String>? additionalSignupData) {
    _additionalSignupData = additionalSignupData;
    notifyListeners();
  }

  List<TermOfServiceResult> getTermsOfServiceResults() {
    return termsOfService
        .map((e) => TermOfServiceResult(term: e, accepted: e.getStatus()))
        .toList();
  }
}
