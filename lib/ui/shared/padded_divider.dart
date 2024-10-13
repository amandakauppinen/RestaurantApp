import 'package:flutter/material.dart';

/// Builds a divider with vertical padding
class PaddedDivider extends StatelessWidget {
  const PaddedDivider({super.key});

  @override
  Widget build(BuildContext context) {
    double padding = 8.0;
    return Padding(padding: EdgeInsets.symmetric(vertical: padding), child: const Divider());
  }
}
