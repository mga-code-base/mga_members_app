import 'package:flutter/material.dart';

class SetInputController {
  TextEditingController weightCtrl;
  TextEditingController repsCtrl;
  String scaleType;
  List<SubsetInputController> subsets;

  SetInputController({
    required this.weightCtrl,
    required this.repsCtrl,
    this.scaleType = 'kg',
    List<SubsetInputController>? subsets,
  }) : subsets = subsets ?? [];

  void dispose() {
    weightCtrl.dispose();
    repsCtrl.dispose();
    for (var sub in subsets) {
      sub.dispose();
    }
  }
}

class SubsetInputController {
  TextEditingController weightCtrl;
  TextEditingController repsCtrl;

  SubsetInputController({
    required this.weightCtrl,
    required this.repsCtrl,
  });

  void dispose() {
    weightCtrl.dispose();
    repsCtrl.dispose();
  }
}
