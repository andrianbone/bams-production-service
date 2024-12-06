// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../auth/authentication.dart';
import '../../bloc/login_bloc.dart';
import '../../storage/shared_pref.dart';
import '../../validator/validator.dart';
import '../home.dart';
import '../login/login_contract.dart';
import '../login/login_interactor_impl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';

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
  String _version = '';

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
    _getVersionInfo();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _loginBloc = LoginBloc(LoginInteractorImpl(LoginApi()));
    _subscription = _loginBloc!.message$!.listen(_handleLoginMessage);
  }

  Future<void> _getVersionInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    // print("Version: ${packageInfo.version}, Build: ${packageInfo.buildNumber}");
    setState(() {
      _version = packageInfo.version; // Versi aplikasi
      // _buildNumber = packageInfo.buildNumber; // Kode versi (build)
    });
  }

  @override
  void dispose() {
    _subscription!.cancel();
    // _loginBloc!.dispose!();
    _loginBloc?.dispose?.call(); // Avoid calling if null.
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
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        return;
      }
    } catch (e) {
      print(e);
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white, // Changed text color
            fontWeight: FontWeight.w600, // Changed font weight
            fontSize: 16, // Increased font size
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.blueGrey[800], // Changed background color
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // More rounded corners
          side: const BorderSide(color: Colors.blue, width: 2), // Added border
        ),
        margin: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 10), // Adjusted margin
        duration: const Duration(seconds: 4), // Increased duration
        // action: SnackBarAction(
        //   label: '', // Changed action label
        //   textColor: Colors.white, // Changed action text color
        //   onPressed: () {
        //     // Handle undo action here
        //   },
        // ),
      ),
    );
  }

  void _showSnackBar1(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.white, // Text color
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.blueGrey[900], // Background color
        behavior: SnackBarBehavior.floating, // Makes it float above the layout
        shape: RoundedRectangleBorder(
          // Rounded corners
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16), // Margin around the Snackbar
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          // Optional action button
          label: '',
          textColor: Colors.orange,
          onPressed: () {
            // Handle undo action here
          },
        ),
      ),
    );
  }

  void _handleLoginMessage(LoginMessage message) async {
    var singleVal = await sharedPref.read("user");
    if (singleVal != null) {
      _showSnackBar('Sign in successfully..');

      await Future.delayed(const Duration(seconds: 1));
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
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
                    // Color.fromARGB(255, 5, 85, 206),
                    // Color.fromARGB(255, 21, 67, 84),
                    Color.fromARGB(255, 14, 14, 15),
                    Color(0xFF00abff),
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
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
          SizedBox(
            height: MediaQuery.of(context).size.height *
                0.05, // 10% dari tinggi layar
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
                      stream: _loginBloc?.usernameError$,
                      builder: (context, snapshot) {
                        // final errorMessage = _getMessage(snapshot.data ?? {});
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
                            labelText: 'Username',
                            // errorText: errorMessage,
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
                            labelText: 'Password',
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
                    height: 10,
                  ),
                  InkWell(
                    onTap: _loginBloc!.submitLogin,
                    // onTap: () async {
                    //   await Navigator.pushReplacement(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => const HomePage()),
                    //   );
                    // },
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
          SizedBox(
            height: MediaQuery.of(context).size.height *
                0.08, // 10% dari tinggi layar
          ),
          // const SizedBox(
          //   height: 50,
          // ),
          InkWell(
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  // "IT Broadcast Developer Version 1.0"
                  'IT Broadcast Developer',
                ),
              ],
            ),
            onTap: () {
              // Navigator.pushNamed(context, '/signup');
            },
          ),
          const SizedBox(
            height: 10,
          ),
          InkWell(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  // "IT Broadcast Developer Version 1.0"
                  'Version: $_version',
                  // 'Version: 1.0',
                ),
              ],
            ),
            onTap: () {},
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
