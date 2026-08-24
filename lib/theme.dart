import 'package:flutter/material.dart';

const Color kSeedColor = Color(0xFF16655B);
const Color kInRangeColor = Color(0xFF2E7D32);
const Color kAboveColor = Color(0xFFB26B00);
const Color kUrgentColor = Color(0xFFC62828);
const Color kInfoColor = Color(0xFF1565C0);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: kSeedColor);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFF4F7F6),
  );
}
