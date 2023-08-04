import 'package:flutter/material.dart';

class AppColorScheme {
  static const ColorScheme appColorScheme = ColorScheme(
primary: Color(0xFF283747), // Dark blue
      secondary: Colors.white, // White
      surface: Color.fromARGB(255, 200, 198, 198), // Light gray
      background: Colors.grey, // Light gray
      error: Colors.red, // Red
      onPrimary: Colors.white, // White (text/icon color on primary color)
      onSecondary: Colors.black, // Black (text/icon color on secondary color)
      onSurface:
          Color.fromARGB(255, 12, 12, 12), // Black (text color on surface)
      onBackground: Colors.black, // Black (text color on background)
      onError: Colors.white, // White (text color on error)
      brightness: Brightness.light, //
  );
}
