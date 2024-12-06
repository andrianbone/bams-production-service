// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../auth/authentication.dart';
import '../../bloc/login_bloc.dart';
import '../../storage/shared_pref.dart';
import '../../validator/validator.dart';
import '../login/login_contract.dart';
import '../login/login_interactor_impl.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  LoginBloc? _loginBloc;
  // ignore: cancel_subscriptions
  StreamSubscription? _subscription;
  SharedPref sharedPref = SharedPref();
  bool _isHidePassword = false;

  @override
  // ignore: override_on_non_overriding_member
  void _tooglePasswordVisibility() {
    setState(() {
      _isHidePassword = !_isHidePassword;
    });
  }

  @override
  void initState() {
    super.initState();

    loadSingleValSharedPrefs();
    _loginBloc = LoginBloc(LoginInteractorImpl(LoginApi()));
    _subscription = _loginBloc!.message$!.listen(_handleLoginMessage);
  }

  @override
  void dispose() {
    _subscription!.cancel();
    _loginBloc!.dispose!();

    super.dispose();
  }

  loadSingleValSharedPrefs() async {
    try {
      var singleVal = await sharedPref.read("user");
      var jsonResponse = json.decode(singleVal);
      // print(jsonResponse.isNotEmpty);

      if (jsonResponse.isNotEmpty) {
        // User user = User.fromJson(jsonResponse);
        // print(user.userid ?? "Empty");
        // print(user.usermail ?? "Empty");

        // if (user.userid.isNotEmpty) {
        // _showSnackBar('Sign in successfully');

        // await Future.delayed(const Duration(seconds: 2));
        // await Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const HomePage()),
        // );
        // return;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    const sizedBox = SizedBox(height: 24.0);

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/loginBg.jpg"),
            fit: BoxFit.cover,
          ),
          color: Colors.white12,
        ),
        child: Container(
          // color: Colors.green.withOpacity(0.5),
          // constraints: const BoxConstraints.expand(),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(0),
              topLeft: Radius.circular(0),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
            color: Colors.blueAccent.withOpacity(0.2),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.grey,
            //     offset: Offset(0.0, 1.0), //(x,y)
            //     blurRadius: 5.0,
            //   ),
            // ],
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    headerSection(),
                    sizedBox,
                    // _buildEmailField(),
                    _buildUsernameField(),
                    _buildPasswordField(),
                    sizedBox,
                    _buildLoadingIndicator(),
                    sizedBox,
                    _buildLoginButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget headerSection() {
    return Container(
      margin: const EdgeInsets.only(top: 50.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: const Center(
        child: Image(
          image: AssetImage('assets/logo-bams.png'),
          width: 500,
          height: 40,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loginBloc!.submitLogin,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        child: const Text('SIGN IN'),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return StreamBuilder<bool>(
      stream: _loginBloc!.isLoading$,
      initialData: _loginBloc!.isLoading$!.value,
      builder: (context, AsyncSnapshot snapshot) {
        return Opacity(
          opacity: snapshot.data ? 1.0 : 0.0,
          child: const CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildPasswordField() {
    return StreamBuilder<Set<ValidationError>>(
      stream: _loginBloc!.passwordError$,
      builder: (context, snapshot) {
        return TextField(
          keyboardType: TextInputType.text,
          obscureText: _isHidePassword,
          maxLines: 1,
          onChanged: _loginBloc!.passwordChanged,
          decoration: InputDecoration(
            icon: Icon(
              _isHidePassword ? Icons.visibility_off : Icons.visibility,
              color: _isHidePassword ? Colors.black : Colors.blue,
            ),
            // errorText: _getMessage(snapshot.data!),
            labelText: 'Password',
          ),
          onTap: () {
            _tooglePasswordVisibility();
          },
        );
      },
    );
  }

  // Widget _buildEmailField() {
  //   return StreamBuilder<Set<ValidationError>>(
  //     stream: _loginBloc.emailError$,
  //     builder: (context, snapshot) {
  //       return TextField(
  //         keyboardType: TextInputType.emailAddress,
  //         maxLines: 1,
  //         onChanged: _loginBloc.emailChanged,
  //         decoration: InputDecoration(
  //           errorText: _getMessage(snapshot.data),
  //           labelText: 'Email',
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildUsernameField() {
    return StreamBuilder<Set<ValidationError>>(
      stream: _loginBloc?.usernameError$,
      builder: (context, snapshot) {
        return TextField(
          keyboardType: TextInputType.text,
          maxLines: 1,
          onChanged: _loginBloc?.usernameChanged,
          decoration: const InputDecoration(
            icon: Icon(
              Icons.account_circle,
              color: Colors.black,
            ),
            fillColor: Colors.black,
            // errorText: _getMessage(snapshot.data!),
            labelText: 'Username',
          ),
        );
      },
    );
  }

  void _showSnackBar(String msg) {
    // ignore: deprecated_member_use
    // _scaffoldKey.currentState?.showSnackBar(
    //   SnackBar(
    //     content: Text(msg),
    //     duration: const Duration(seconds: 2),
    //   ),
    // );

    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[850],
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _handleLoginMessage(LoginMessage message) async {
    print('[Login Page]$message');
    print('[Login Page]$LoginSuccessMessage');

    // ignore: avoid_init_to_null
    var singleVal = await sharedPref.read("user");
    if (singleVal != null) {
      // var jsonResponse = json.decode(singleVal);
      // User user = User.fromJson(jsonResponse);
      _showSnackBar('Sign in successfully');

      await Future.delayed(const Duration(seconds: 1));
      // await Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const HomePage()),
      // );
      return;
    }

    if (message is LoginErrorMessage) {
      return _showSnackBar(message.error.toString());
    }
    if (message is InvalidInformationMessage) {
      return _showSnackBar(
          'Harap pastikan Username dan Password anda sudah terisi dengan benar!');
    }
  }

  String _getMessage(Set<ValidationError> errors) {
    // ignore: unnecessary_null_comparison
    if (errors == null || errors.isEmpty) {
      return '';
    }
    if (errors.contains(ValidationError.invalidEmail)) {
      return 'Invalid email address';
    }
    if (errors.contains(ValidationError.invalidUsername)) {
      return 'Invalid username';
    }
    if (errors.contains(ValidationError.tooShortPassword)) {
      return 'Password must be at least 6 characters';
    }
    return '';
  }
}
