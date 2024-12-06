import 'package:connectivity/connectivity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/cubit/internet_cubit.dart';
import 'package:flutter/material.dart';
import 'pages/splashscreen.dart';

void main() {
  runApp(MyApp(
    connectivity: Connectivity(),
  ));
}

class MyApp extends StatelessWidget {
  final Connectivity? connectivity;

  const MyApp({
    super.key,
    @required this.connectivity,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<InternetCubit>(
          create: (context) => InternetCubit(connectivity: connectivity!),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'BAMS Prodction Service',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.lightBlue[800],
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Colors.cyan[600]),
          useMaterial3: true,
        ),
        // home: LoginPage(),
        home: const SplashScreenPage(),
      ),
    );
  }
}
