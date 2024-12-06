extension ValidationExtension on String {
  bool isValidPassword() {
    return length >= 6;
  }

  bool isValidUsername() {
    return length >= 6;
  }

  bool isValidEmail() {
    const emailRegExpString = r'[a-zA-Z0-9\+\.\_\%\-\+]{1,256}\@[a-zA-Z0-9]'
        r'[a-zA-Z0-9\-]{0,64}(\.[a-zA-Z0-9][a-zA-Z0-9\-]{0,25})+';
    return RegExp(emailRegExpString, caseSensitive: false).hasMatch(this);
  }
}

enum ValidationError { invalidEmail, invalidUsername, tooShortPassword }

class Validator {
  const Validator();

  /// return set of [ValidationError]s (return empty set if email is valid)
  Set<ValidationError> validateEmail(String email) {
    if (email.isValidEmail()) {
      return const {};
    }
    return {ValidationError.invalidEmail};
  }

  Set<ValidationError> validateUsername(String username) {
    if (username.isValidUsername()) {
      return const {};
    }
    return {ValidationError.invalidUsername};
  }

  /// return set of [ValidationError]s (return empty set if password is valid)
  Set<ValidationError> validatePassword(String password) {
    if (password.isValidPassword()) {
      return const {};
    }
    return {ValidationError.tooShortPassword};
  }
}
