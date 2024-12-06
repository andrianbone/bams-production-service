// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class WidgetPadding extends StatelessWidget {
  final double _height;

  const WidgetPadding(this._height);

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.all(30.0),
      // padding: EdgeInsets.all(10.0),
      // alignment: Alignment.topCenter,
      // width: 200,
      height: _height,
    );
  }
}
