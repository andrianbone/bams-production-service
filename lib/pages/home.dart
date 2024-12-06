// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:convert';

import 'package:bams_production_service_apps/pages/bo_list_out.dart';
import 'package:bams_production_service_apps/pages/checkin_list.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../bloc/cubit/internet_cubit.dart';
import '../constants/enums.dart';
import '../storage/shared_pref.dart';
import '../widget/internet.dart';
import '../widget/menu.dart';
import '../widget/padding.dart';
import 'login/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime now = DateTime.now();

  final TextStyle whiteText = const TextStyle(color: Colors.white);

  SharedPref sharedPref = SharedPref();
  String? username;
  String? email;
  // final BoDetailOutBloc _orderDetailBloc = BoDetailOutBloc();
  int questionIndex = 0;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    checkConnection();
    super.initState();
    loadSingleValSharedPrefs();
  }

  void _onExitApps(Choice choice) {
    if (choice.title == 'Logout') {
      onWillPop2();
    }
  }

  void checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      BlocProvider.of<InternetCubit>(context)
          .emitInternetConnected(ConnectionType.mobile);
    } else if (connectivityResult == ConnectivityResult.wifi) {
      BlocProvider.of<InternetCubit>(context)
          .emitInternetConnected(ConnectionType.wifi);
    } else if (connectivityResult == ConnectivityResult.none) {
      BlocProvider.of<InternetCubit>(context).emitInternetDisconnected();
    }
  }

  void loadSingleValSharedPrefs() async {
    try {
      var singleVal = await sharedPref.read("user");
      var jsonResponse = json.decode(singleVal);

      setState(() {
        username = jsonResponse['username'];
        email = jsonResponse['usermail'];
      });
    } catch (e) {
      print(e);
    }
  }

  void _showSnackBar(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey[850],
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _showDialogCheckOutIn() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white70, // Custom background color
            content: Stack(
              children: <Widget>[
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.red,
                      radius:
                          20, // Adjust the size of the CircleAvatar if needed
                      child: Icon(Icons.close),
                    ),
                  ),
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(Colors.black87),
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        side: const BorderSide(
                                            color: Colors.black87)))),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const BookingOrderOutListPage()),
                          );
                        },
                        child: const Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.logout_outlined,
                                  color: Colors.white,
                                ),
                                Text(
                                  " Check Out",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontFamily: 'Raleway'),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      const WidgetPadding(20),
                      TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(Colors.black87),
                            shape:
                                WidgetStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        side: const BorderSide(
                                            color: Colors.black87)))),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const CheckInListPage()),
                          );
                        },
                        child: const Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.login_outlined,
                                  color: Colors.white,
                                ),
                                Text(
                                  " Check In",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontFamily: 'Raleway'),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  DateTime? currentBackPressTime;

  Object onWillPop2() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white, // Custom background color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          title: const Text('Exit App'),
          content: const Text('Do you really want to Exit?'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'No',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white, // Customize the button text color
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => {
                // setState(() async {
                // }),
                // _orderDetailBloc.clearAllDb(),
                sharedPref.remove("user"),
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const LoginPage()))
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Yes',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white, // Customize the button text color
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: const Row(
          children: <Widget>[
            Image(
              image: AssetImage('assets/logo-bams.png'),
            ),
            Text(
              "-  Home",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15.0),
            ),
          ],
        ),
        actions: <Widget>[WidgetMenu(_onExitApps, username, email)],
      ),
      backgroundColor: Colors.white,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    String formattedDate = DateFormat('EEEE, d MMM y').format(now);
    return SingleChildScrollView(
      child: Stack(children: <Widget>[
        IndexedStack(
          index: 0,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Container(
                //   width: MediaQuery.of(context).size.width,
                //   height: MediaQuery.of(context).size.height / 6,
                //   decoration: const BoxDecoration(
                //       gradient: LinearGradient(
                //         begin: Alignment.topCenter,
                //         end: Alignment.bottomCenter,
                //         colors: [
                //           // Color.fromARGB(255, 5, 85, 206),
                //           // Color.fromARGB(255, 21, 67, 84),
                //           Color.fromARGB(255, 14, 14, 15),
                //           Color(0xFF00abff),
                //         ],
                //       ),
                //       borderRadius:
                //           BorderRadius.only(bottomLeft: Radius.circular(90))),
                //   child: const Column(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: <Widget>[
                //       Spacer(),
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           Image(image: AssetImage('assets/logo-bams.png')),
                //           Text(
                //             'Production Service',
                //             //  'Production Service\nProduction Service',
                //             style: TextStyle(
                //                 fontSize: 12, fontWeight: FontWeight.bold),
                //           ),
                //         ],
                //       ),
                //       Spacer(),
                //     ],
                //   ),
                // ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 25.0, 10, 10.0),
                  decoration: const BoxDecoration(
                    // borderRadius: BorderRadius.only(
                    //   bottomLeft: Radius.circular(50.0),
                    //   bottomRight: Radius.circular(50.0),
                    // ),
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(60)),
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
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          "WELCOME \nBams Production Service",
                          style: whiteText.copyWith(
                              fontWeight: FontWeight.bold, fontSize: 17.0),
                          textAlign: TextAlign.left,
                        ),
                        trailing: ClipOval(
                            child: Image.asset(
                          'assets/icon.png',
                          fit: BoxFit.contain,
                          matchTextDirection: true,
                          height: 30,
                        )),
                      ),
                      const SizedBox(height: 10.0),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 16.0),
                      //   child: Text(
                      //     "WELCOME",
                      //     style: whiteText.copyWith(
                      //       fontSize: 18.0,
                      //       fontWeight: FontWeight.w500,
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 5.0),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 16.0),
                      //   child: Text(
                      //     "Broadcast Assets\nManagement System",
                      //     style: whiteText,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Card(
                  elevation: 4.0,
                  color: Colors.white,
                  margin: const EdgeInsets.all(16.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: ListTile(
                          leading: Container(
                            alignment: Alignment.center,
                            width: 45.0,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  height: 20,
                                  width: 8.0,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(width: 4.0),
                                Container(
                                  height: 25,
                                  width: 8.0,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(width: 4.0),
                                Container(
                                  height: 40,
                                  width: 8.0,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 4.0),
                                Container(
                                  height: 30,
                                  width: 8.0,
                                  color: Colors.grey.shade300,
                                ),
                              ],
                            ),
                          ),
                          title: const Text("BAMS Production Service"),
                          //  title: const Text("BAMS Production Service"),
                          subtitle: Text(formattedDate),
                        ),
                      ),
                      const VerticalDivider(),
                    ],
                  ),
                ),
                const SizedBox(height: 30.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const BookingOrderOutListPage()),
                            );
                          },
                          child: _buildTile(
                            color: const Color.fromARGB(255, 26, 78, 150),
                            icon: Icons.logout_outlined,
                            title: "Check Out",
                            data: "bo_list",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CheckInListPage()),
                            );
                          },
                          child: _buildTile(
                            color: const Color.fromARGB(255, 36, 150, 26),
                            icon: Icons.login_outlined,
                            title: "Check In",
                            data: "bo_list",
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: 15.0),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //   child: Row(
                //     children: <Widget>[
                //       Expanded(
                //         child: _buildTile(
                //           color: Colors.blue,
                //           icon: Icons.find_replace,
                //           title: "Replacement",
                //           data: "replacement",
                //         ),
                //       ),
                //       const SizedBox(width: 16.0),
                //       Expanded(
                //         child: _buildTile(
                //           color: Colors.pink,
                //           icon: Icons.history,
                //           title: "History",
                //           data: "history",
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                const SizedBox(height: 20.0),
              ],
            )
          ],
        ),
        const InternetWgt(),
      ]),
    );
  }

  Container _buildTile(
      {Color? color, IconData? icon, String? title, String? data}) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      height: 150.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Icon(
            icon,
            color: Colors.white,
          ),
          Text(
            title!,
            style:
                whiteText.copyWith(fontWeight: FontWeight.bold, fontSize: 18.0),
          ),
          InkWell(
            onTap: () {
              // if (data == 'bo_list') {
              //   _showDialogCheckOutIn();
              // } else {
              //   _showSnackBar('Comming Soon');
              // }
            },
            child: Row(
              children: [
                Text(
                  'Click Here',
                  style: whiteText.copyWith(
                      fontWeight: FontWeight.bold, fontSize: 15.0),
                ),
                const Icon(
                  Icons.arrow_right_sharp,
                  color: Colors.white,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
