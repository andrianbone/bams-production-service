import 'dart:async';

import 'package:disposebag/disposebag.dart';
// ignore: depend_on_referenced_packages
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import '../validator/validator.dart';
import '../pages/login/login_contract.dart';

// ignore_for_file: close_sinks

class LoginBloc {
  // final void Function(String) emailChanged;
  final void Function(String)? usernameChanged;
  final void Function(String)? passwordChanged;
  final void Function()? submitLogin;

  /// Streams
  // final Stream<Set<ValidationError>> emailError$;
  final Stream<Set<ValidationError>>? usernameError$;
  final Stream<Set<ValidationError>>? passwordError$;
  final ValueStream<bool>? isLoading$;
  final Stream<LoginMessage>? message$;

  /// Clean up
  final void Function()? dispose;

  LoginBloc._({
    // @required this.emailChanged,
    @required this.usernameChanged,
    @required this.passwordChanged,
    @required this.submitLogin,
    // @required this.emailError$,
    @required this.usernameError$,
    @required this.passwordError$,
    @required this.isLoading$,
    @required this.message$,
    @required this.dispose,
  });

  factory LoginBloc(LoginInteractor interactor) {
    // assert(interactor != null);
    const validator = Validator();

    // Stream controllers
    // final emailS = BehaviorSubject.seeded('');
    final usernameS = BehaviorSubject.seeded('');
    final passwordS = BehaviorSubject.seeded('');
    final isLoadingS = BehaviorSubject.seeded(false);
    final submitLoginS = StreamController<void>();
    // final subjects = [emailS, passwordS, isLoadingS, submitLoginS];
    final subjects = [usernameS, passwordS, isLoadingS, submitLoginS];

    // Email error and password error stream
    // final emailError$ = emailS.map(validator.validateEmail).distinct().share();
    final usernameError$ =
        usernameS.map(validator.validateUsername).distinct().share();

    final passwordError$ =
        passwordS.map(validator.validatePassword).distinct().share();

    // Submit stream
    final submit$ = submitLoginS.stream
        .throttleTime(const Duration(milliseconds: 500))
        .withLatestFrom<bool, bool>(
          Rx.combineLatest<Set<ValidationError>, bool>(
            // [emailError$, passwordError$],
            [usernameError$, passwordError$],
            (listOfSets) => listOfSets.every((errorsSet) => errorsSet.isEmpty),
          ),
          (_, isValid) => isValid,
        )
        .share();

    // Message stream
    final message$ = Rx.merge(
      [
        submit$
            .where((isValid) => isValid)
            .withLatestFrom2(
              // emailS,
              usernameS,
              passwordS,
              // (_, email, password) => Credential(
              (_, username, password) => Credential(
                // email: email,
                username: username.toString(),
                password: password.toString(),
              ),
            )
            .exhaustMap(
              (credential) => interactor.performLogin(
                credential,
                isLoadingS,
              ),
            ),
        submit$
            .where((isValid) => !isValid)
            .map((_) => const InvalidInformationMessage()),
      ],
    ).publish();

    return LoginBloc._(
      // emailChanged: emailS.add,
      usernameChanged: usernameS.add,
      passwordChanged: passwordS.add,
      submitLogin: () => submitLoginS.add(null),
      // emailError$: emailError$,
      usernameError$: usernameError$,
      passwordError$: passwordError$,
      isLoading$: isLoadingS.stream,
      message$: message$,
      dispose: DisposeBag([message$.connect(), ...subjects]).dispose,
    );
  }
}
