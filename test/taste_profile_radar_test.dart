import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:winemind/features/wine/presentation/widgets/taste_profile_radar.dart';

void main() {
  group('TasteProfileRadar', () {
    Future<RadarChartData> pumpAndReadData(
      WidgetTester tester, {
      required double body,
      required double tannin,
      required double fruit,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TasteProfileRadar(
              bodyLevel: body,
              tanninLevel: tannin,
              fruitLevel: fruit,
            ),
          ),
        ),
      );
      final radar = tester.widget<RadarChart>(find.byType(RadarChart));
      return radar.data;
    }

    testWidgets('ancre l\'échelle sur [0,1] via deux datasets fantômes',
        (tester) async {
      final data = await pumpAndReadData(
        tester,
        body: 0.5,
        tannin: 0.35,
        fruit: 0.8,
      );

      // 3 datasets : fantôme 0, fantôme 1, données réelles.
      expect(data.dataSets.length, 3);

      double minOf(RadarDataSet ds) =>
          ds.dataEntries.map((e) => e.value).reduce((a, b) => a < b ? a : b);
      double maxOf(RadarDataSet ds) =>
          ds.dataEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

      // Le minimum global de tous les datasets doit être 0 (centre = 0)
      // et le maximum global 1 (bord = 1), indépendamment des valeurs réelles.
      final globalMin =
          data.dataSets.map(minOf).reduce((a, b) => a < b ? a : b);
      final globalMax =
          data.dataSets.map(maxOf).reduce((a, b) => a > b ? a : b);
      expect(globalMin, 0.0, reason: 'le centre du radar doit valoir 0');
      expect(globalMax, 1.0, reason: 'le bord du radar doit valoir 1');

      // Un dataset d'ancrage vaut exactement [0,0,0], un autre [1,1,1].
      expect(
        data.dataSets.any((ds) => ds.dataEntries.every((e) => e.value == 0.0)),
        isTrue,
      );
      expect(
        data.dataSets.any((ds) => ds.dataEntries.every((e) => e.value == 1.0)),
        isTrue,
      );

      // Les valeurs réelles sont bien présentes telles quelles.
      final realValues =
          data.dataSets.last.dataEntries.map((e) => e.value).toList();
      expect(realValues, [0.5, 0.35, 0.8]);
    });

    test('canRender exige les 3 niveaux', () {
      expect(TasteProfileRadar.canRender(0.5, 0.5, 0.5), isTrue);
      expect(TasteProfileRadar.canRender(null, 0.5, 0.5), isFalse);
      expect(TasteProfileRadar.canRender(0.5, null, 0.5), isFalse);
      expect(TasteProfileRadar.canRender(0.5, 0.5, null), isFalse);
    });
  });
}
