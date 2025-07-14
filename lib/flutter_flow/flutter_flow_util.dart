import 'package:flutter/material.dart';

class FFAppState extends ChangeNotifier {
  static final FFAppState _instance = FFAppState._internal();
  factory FFAppState() => _instance;
  FFAppState._internal();

  int selectHomeIndex = 0;

  void update() => notifyListeners();
}

extension ListUtils<T> on List<T> {
  List<T> divide(Widget divider) => this;
}
