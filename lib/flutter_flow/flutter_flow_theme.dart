import 'package:flutter/material.dart';

class FlutterFlowTheme {
  static FlutterFlowTheme of(BuildContext context) => FlutterFlowTheme();

  Color get primaryText => Colors.black;
  Color get secondaryBackground => Colors.white;
  Color get textfiled => Colors.grey;
  Color get secondary => Colors.pink.shade100;

  TextStyle get bodyMedium => const TextStyle();
}
