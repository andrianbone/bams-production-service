import 'package:flutter/material.dart';

Widget loadingWidget(BuildContext context) {
  return const CircularProgressIndicator(
    backgroundColor: Colors.blue,
    valueColor:  AlwaysStoppedAnimation<Color>(Colors.green),
  );
}
