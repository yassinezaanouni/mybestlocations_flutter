import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  GoogleMapController? _mapController;

  bool get isDarkMode => _isDarkMode;
  static String get darkMapStyle => _darkMapStyle ?? '';
  static String get lightMapStyle => _lightMapStyle ?? '';

  void setMapController(GoogleMapController controller) {
    _mapController = controller;
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    if (_mapController != null) {
      _mapController!.setMapStyle(_isDarkMode ? darkMapStyle : lightMapStyle);
    }
    notifyListeners();
  }

  static String? _darkMapStyle;
  static String? _lightMapStyle;

  static Future<void> loadMapStyles() async {
    _darkMapStyle = await rootBundle.loadString('assets/map_dark.json');
    _lightMapStyle = await rootBundle.loadString('assets/map_light.json');
  }
}
