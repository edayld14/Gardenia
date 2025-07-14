import 'package:flutter/material.dart';

class AnasayfaModel {
  void dispose() {}

  // Alt bar için modüller varsa tanımlanabilir
  final homeComponetModel = Object();
  final favComponetModel = Object();
  final chatComopnetModel = Object();
  final profileComponetModel = Object();
}

AnasayfaModel createModel(
  BuildContext context,
  AnasayfaModel Function() modelBuilder,
) {
  return modelBuilder();
}

void safeSetState(VoidCallback fn) {
  fn();
}
