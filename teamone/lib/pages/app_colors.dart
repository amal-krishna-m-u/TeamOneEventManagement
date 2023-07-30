import 'package:flutter/material.dart';

class AppColorScheme {
  static const ColorScheme appColorScheme = ColorScheme(
    primary: Color(0xFF283747), // Dark blue
    primaryVariant: Color(0xFF283747), // Dark blue variant
    secondary: Colors.white, // White
    secondaryVariant: Colors.white, // White variant
    surface: Color.fromARGB(255, 200, 198, 198), // Light gray
    background: Colors.grey, // Light gray
    error: Colors.red, // Red
    onPrimary: Colors.white, // White (text/icon color on primary color)
    onSecondary: Colors.black, // Black (text/icon color on secondary color)
    onSurface: Color.fromARGB(255, 12, 12, 12), // Black (text color on surface)
    onBackground: Colors.black, // Black (text color on background)
    onError: Colors.white, // White (text color on error)
    brightness: Brightness.light, // Set to Brightness.light for light theme
  );
}
