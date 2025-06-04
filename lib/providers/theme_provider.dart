import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode
      ? ThemeData.dark().copyWith(
          primaryColor: Colors.blueGrey,
          colorScheme: const ColorScheme.dark(primary: Colors.blueGrey),
        )
      : ThemeData.light().copyWith(
          primaryColor: Colors.blue,
          colorScheme: const ColorScheme.light(primary: Colors.blue),
        );

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}