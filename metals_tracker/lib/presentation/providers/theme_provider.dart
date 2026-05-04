import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// This Notifier controls the ThemeMode (light, dark, or system)
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Defaults to following the user's iOS/Android system settings
    return ThemeMode.system;
  }

  void updateTheme(ThemeMode mode) {
    state = mode;
  }
}

// The provider will be watched in UI
final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});
