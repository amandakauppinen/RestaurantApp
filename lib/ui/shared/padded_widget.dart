import 'package:flutter/material.dart';

/// Builds a [vertical] or horizontal 'empty' widget with optional [multiplier]
/// to increase the padding
class PaddedWidget extends StatelessWidget {
  final bool vertical;
  final double multiplier;

  const PaddedWidget({this.vertical = true, this.multiplier = 1, super.key});

  @override
  Widget build(BuildContext context) {
    double paddingValue = 10 * multiplier;
    return Padding(
        padding: EdgeInsets.symmetric(
            vertical: vertical ? paddingValue : 0, horizontal: vertical ? 0 : paddingValue));
  }
}
