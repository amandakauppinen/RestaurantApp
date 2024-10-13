import 'package:flutter/material.dart';

/// Builds a star used to indicate favourites
/// Executes provided [onClick] and display is modified based on [isSelected]
class FavouritesStar extends StatefulWidget {
  final Function(bool) onClick;
  final bool isSelected;

  const FavouritesStar({
    required this.isSelected,
    required this.onClick,
    super.key,
  });

  @override
  State<FavouritesStar> createState() => _FavouritesStarState();
}

class _FavouritesStarState extends State<FavouritesStar> {
  bool initialised = false;
  late bool isSelected;

  @override
  Widget build(BuildContext context) {
    if (initialised == false) {
      isSelected = widget.isSelected;
      initialised = true;
    }

    return InkWell(
        onTap: () => setState(() {
              isSelected = !isSelected;
              widget.onClick(isSelected);
            }),
        child: Icon(isSelected ? Icons.star_rounded : Icons.star_border_rounded,
            size: 36, color: Colors.black));
  }
}
