import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuraTheme', () {
    test('light theme uses Material 3 and AuraColors', () {
      final theme = AuraTheme.light();
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, AuraColors.background);
      expect(theme.appBarTheme.backgroundColor, AuraColors.primary);
    });

    test('dark theme uses Material 3 and dark brightness', () {
      final theme = AuraTheme.dark();
      expect(theme.useMaterial3, isTrue);
      expect(theme.brightness, Brightness.dark);
      expect(theme.appBarTheme.backgroundColor, AuraColors.primaryDark);
    });
  });
}
