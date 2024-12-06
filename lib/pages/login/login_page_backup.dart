// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../auth/authentication.dart';
import '../../bloc/login_bloc.dart';
import '../../storage/shared_pref.dart';
import '../../validator/validator.dart';
import '../login/login_contract.dart';
import '../login/login_interactor_impl.dart';

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // final _scaffoldKey = GlobalKey<ScaffoldState>();

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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
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
        return;
      }
    } catch (e) {
      print(e);
    }
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
      // return;
    }

    if (message is LoginErrorMessage) {
      return _showSnackBar(message.error.toString());
    }
    if (message is InvalidInformationMessage) {
      return _showSnackBar(
          'Harap pastikan Username dan Password anda sudah terisi dengan benar!');
    }
  }

  String? _getMessage(Set<ValidationError> errors) {
    if (errors.isEmpty) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 6,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 5, 85, 206),
                    Color.fromARGB(255, 21, 67, 84)
                  ],
                ),
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(90))),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(image: AssetImage('assets/logo-bams.png')),
                    Text(
                      'Production Service',
                      //  'Production Service\nProduction Service',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                // SizedBox(
                //   height: 10,
                // ),
                // Text(
                //   'Manage Your Asset',
                //   style: TextStyle(
                //       color: Colors.black87, fontWeight: FontWeight.bold),
                // ),
                // Text(
                //   'Manage Your Inventory',
                //   style: TextStyle(
                //       color: Colors.black87, fontWeight: FontWeight.bold),
                // ),
                Spacer(),
              ],
            ),
          ),
          Container(
            height: 450,
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.only(top: 62),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 10, bottom: 20),
                  //   child: Text('USERNAME', style: TextStyle(fontSize: 15)),
                  // ),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: 60,
                    padding: const EdgeInsets.only(
                        top: 4, left: 16, right: 16, bottom: 4),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 5)
                        ]),
                    child: StreamBuilder<Set<ValidationError>>(
                      stream: _loginBloc!.usernameError$,
                      builder: (context, snapshot) {
                        return TextField(
                          keyboardType: TextInputType.text,
                          maxLines: 1,
                          onChanged: _loginBloc!.usernameChanged,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              Icons.account_circle,
                              color: Colors.black,
                            ),
                            fillColor: Colors.black,
                            // errorText: _getMessage(snapshot.data!),
                            // labelText: 'Username',
                          ),
                        );
                      },
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 20),
                  //   child: Text('PASSWORD', style: TextStyle(fontSize: 15)),
                  // ),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.2,
                    height: 60,
                    margin: const EdgeInsets.only(top: 32),
                    padding: const EdgeInsets.only(
                        top: 4, left: 16, right: 16, bottom: 4),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 5)
                        ]),
                    child: StreamBuilder<Set<ValidationError>>(
                      stream: _loginBloc!.passwordError$,
                      builder: (context, snapshot) {
                        return TextField(
                          keyboardType: TextInputType.text,
                          obscureText: _isHidePassword,
                          maxLines: 1,
                          onChanged: _loginBloc!.passwordChanged,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              _isHidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color:
                                  _isHidePassword ? Colors.black : Colors.blue,
                            ),
                            // errorText: _getMessage(snapshot.data),
                            // labelText: 'Password',
                          ),
                          onTap: () {
                            _tooglePasswordVisibility();
                          },
                        );
                      },
                    ),
                  ),
                  _buildLoadingIndicator(),
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: _loginBloc!.submitLogin,
                    child: Container(
                      height: 45,
                      width: MediaQuery.of(context).size.width / 1.2,
                      decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(255, 14, 14, 15),
                              Color(0xFF00abff),
                            ],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      child: Center(
                        child: Text(
                          'SIGN IN'.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("IT Broadcast Developer MNC Studios"),
              ],
            ),
            onTap: () {
              // Navigator.pushNamed(context, '/signup');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return StreamBuilder<bool>(
      stream: _loginBloc!.isLoading$,
      initialData: _loginBloc!.isLoading$!.value,
      builder: (context, snapshot) {
        return Opacity(
          opacity: snapshot.data! ? 1.0 : 0.0,
          child: const CircularProgressIndicator(),
        );
      },
    );
  }
}
