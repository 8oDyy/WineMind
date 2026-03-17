// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:winemind/features/wine/domain/entities/wine.dart';

void main() {
  test('Wine entity equality', () {
    const wine1 = Wine(
      name: 'Château Margaux',
      year: '2015',
      type: 'Rouge',
      region: 'Bordeaux, France',
      rating: 3.5,
      points: 95,
      apogee: '2025 - 2045',
      stock: 3,
    );
    const wine2 = Wine(
      name: 'Château Margaux',
      year: '2015',
      type: 'Rouge',
      region: 'Bordeaux, France',
      rating: 3.5,
      points: 95,
      apogee: '2025 - 2045',
      stock: 3,
    );
    expect(wine1, equals(wine2));
  });
}
