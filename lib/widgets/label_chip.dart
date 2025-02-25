import 'package:flutter/material.dart';
import '../models/label.dart';

class LabelChip extends StatelessWidget {
  final Label label;

  const LabelChip({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label.name), backgroundColor: Color(label.color));
  }
}
