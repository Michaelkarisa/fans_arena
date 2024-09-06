import 'package:flutter/material.dart';

extension ColorHex on Color {
  String toHex({bool leadingHashSign = true}) {
    final r = (red < 16 ? '0' : '') + red.toRadixString(16);
    final g = (green < 16 ? '0' : '') + green.toRadixString(16);
    final b = (blue < 16 ? '0' : '') + blue.toRadixString(16);
    return '${leadingHashSign ? '#' : ''}$r$g$b';
  }
}
