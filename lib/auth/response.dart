// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';

@immutable
abstract class LoginResponse {}

class SuccessResponse extends LoginResponse {
  final String token;

  SuccessResponse(this.token);
}

class ErrorResponse extends LoginResponse {
  // ignore: prefer_typing_uninitialized_variables
  final error;

  ErrorResponse(this.error);
}
