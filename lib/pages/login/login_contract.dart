// ignore_for_file: depend_on_referenced_packages

import 'package:meta/meta.dart';

/// Credential contains email and password
class Credential {
  // final String email;
  final String? username;
  final String? password;

  // const Credential({this.email, this.password});
  const Credential({this.username, this.password});

  @override
  // String toString() => 'Credential{email: $email, password: $password}';
  String toString() => 'Credential{username: $username, password: $password}';
}

/// Interactor
abstract class LoginInteractor {
  Stream<LoginMessage> performLogin(
    Credential credential,
    Sink<bool> isLoadingSink,
  );
}

/// Login message
@immutable
abstract class LoginMessage {}

class LoginSuccessMessage implements LoginMessage {
  final String token;

  const LoginSuccessMessage(this.token);
}

class LoginErrorMessage implements LoginMessage {
  final Object error;

  const LoginErrorMessage(this.error);
}

class InvalidInformationMessage implements LoginMessage {
  const InvalidInformationMessage();
}
