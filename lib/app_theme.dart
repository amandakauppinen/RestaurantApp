import 'package:flutter/material.dart';

/// Contains theme definitions used throughout the app
class AppTheme {
  static ThemeData get theme {
    return ThemeData(
        primaryColor: Colors.teal,
        brightness: Brightness.light,
        textTheme: const TextTheme(
            titleMedium:
                TextStyle(fontSize: 22, overflow: TextOverflow.fade, fontWeight: FontWeight.bold)),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black));
  }

  static double listTileTitleSize = 22;
  static double listTileSubtitleSize = 18;
  static double listTileItalicsSize = 12;
}
