import '../bloc/cubit/internet_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InternetWgt extends StatelessWidget {
  // ignore: use_super_parameters
  const InternetWgt({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InternetCubit, InternetState>(
      builder: (context, state) {
        if (state is InternetDisconnected) {
          return Positioned(
            height: 24.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              color: const Color(0xFFEE4400),
              child: const Center(
                child: Text(
                  "OFFLINE",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
