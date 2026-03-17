import 'package:flutter/material.dart';

Color wineTypeColor(String type) {
  switch (type) {
    case 'Rouge':
      return const Color(0xFF7B1A2E);
    case 'Blanc':
      return const Color(0xFFD4AC0D);
    case 'Rosé':
      return const Color(0xFFE8A0A0);
    case 'Champagne':
      return const Color(0xFFC5A028);
    default:
      return Colors.grey;
  }
}
