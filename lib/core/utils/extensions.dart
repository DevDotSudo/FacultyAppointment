import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color lighten([double amount = 0.1]) {
    return Color.lerp(const Color(0xFFFFFFFF), this, amount)!;
  }

  Color darken([double amount = 0.1]) {
    return Color.lerp(const Color(0x00000000), this, amount)!;
  }
}
