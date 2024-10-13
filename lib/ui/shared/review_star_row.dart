import 'package:flutter/material.dart';

/// Builds an interactive row of stars for the user to indicate a review score for
/// a restaurant. [onChanged] is called when the row is [enabled] and the user selects
/// a score. An optional [startingValue] and [iconSize] can be provided to provide a
/// layout for the row. [shrink] sets the row size to minimum where necessary
class ReviewStarRow extends StatefulWidget {
  final Function(num)? onChanged;
  final bool enabled, shrink;
  final num? startingValue;
  final double? iconSize;

  const ReviewStarRow(
      {super.key,
      this.onChanged,
      this.enabled = true,
      this.shrink = false,
      this.startingValue = 0,
      this.iconSize = 24});

  @override
  State<ReviewStarRow> createState() => _ReviewStarRowState();
}

class _ReviewStarRowState extends State<ReviewStarRow> {
  num? score;
  bool addHalf = false;

  @override
  Widget build(BuildContext context) {
    score ??= widget.startingValue ?? 0;
    // Adds half a star if the score decimal would round up
    if (!(score is int || score == score!.roundToDouble()) && (score! - score!.toInt() >= 0.5)) {
      addHalf = true;
      score = score!.floor();
    }

    // Add formatted stars to list, either filled or unfilled
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      bool filled = i <= score!;
      if (addHalf && i == score! + 1) {
        stars.add(Icon(Icons.star_half_rounded, color: Colors.teal, size: widget.iconSize));
      } else {
        stars.add(widget.enabled && widget.onChanged != null
            ? _getIcon(filled, onPressed: () {
                setState(() {
                  score = score == i ? 0 : i;
                  widget.onChanged!(score!);
                });
              })
            : _getIcon(filled));
      }
    }

    return Row(mainAxisSize: widget.shrink ? MainAxisSize.min : MainAxisSize.max, children: stars);
  }

  /// Returns an icon that is [filled] or unfilled with an optional [onPressed] function
  Widget _getIcon(bool filled, {Function()? onPressed}) {
    IconData icon = filled ? Icons.star_rounded : Icons.star_border_rounded;
    return widget.enabled
        ? IconButton(
            icon: Icon(icon, size: widget.iconSize),
            color: Colors.teal,
            onPressed: onPressed ?? () {})
        : Icon(icon, color: Colors.teal, size: widget.iconSize);
  }
}
