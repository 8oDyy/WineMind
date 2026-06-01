import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Radar (toile d'araignée) du profil gustatif d'un vin à 3 axes :
/// Corps, Tanins, Fruit. Les valeurs sont attendues normalisées dans `[0, 1]`
/// (ou `null` si non renseignées).
///
/// Le widget appelant est responsable de ne l'afficher que lorsque les 3
/// niveaux sont disponibles (cf. `TasteProfileRadar.canRender`).
class TasteProfileRadar extends StatelessWidget {
  final double bodyLevel;
  final double tanninLevel;
  final double fruitLevel;

  const TasteProfileRadar({
    super.key,
    required this.bodyLevel,
    required this.tanninLevel,
    required this.fruitLevel,
  });

  /// Vrai si les 3 niveaux gustatifs sont présents et donc affichables.
  static bool canRender(double? body, double? tannin, double? fruit) =>
      body != null && tannin != null && fruit != null;

  static const List<String> _titles = ['Corps', 'Tanins', 'Fruit'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          // Échelle fixe [0, 1] : on borne le radar pour que les niveaux
          // gustatifs soient comparables d'un vin à l'autre.
          isMinValueAtCenter: true,
          dataSets: [
            // Deux datasets fantômes transparents qui FIGENT l'échelle radiale
            // sur [0, 1] : fl_chart calque sinon le centre sur la valeur MIN
            // et le bord sur la valeur MAX des données réelles → un axe à 0.35
            // tomberait au centre (= 0). Avec `[0,0,0]` + `[1,1,1]`, centre = 0
            // et bord = 1, donc value 0.5 → 50 % du rayon, etc.
            RadarDataSet(
              fillColor: Colors.transparent,
              borderColor: Colors.transparent,
              borderWidth: 0,
              entryRadius: 0,
              dataEntries: const [
                RadarEntry(value: 0.0),
                RadarEntry(value: 0.0),
                RadarEntry(value: 0.0),
              ],
            ),
            RadarDataSet(
              fillColor: Colors.transparent,
              borderColor: Colors.transparent,
              borderWidth: 0,
              entryRadius: 0,
              dataEntries: const [
                RadarEntry(value: 1.0),
                RadarEntry(value: 1.0),
                RadarEntry(value: 1.0),
              ],
            ),
            RadarDataSet(
              fillColor: AppColors.primaryWine.withValues(alpha: 0.18),
              borderColor: AppColors.primaryWine,
              borderWidth: 2,
              entryRadius: 2.5,
              dataEntries: [
                RadarEntry(value: bodyLevel),
                RadarEntry(value: tanninLevel),
                RadarEntry(value: fruitLevel),
              ],
            ),
          ],
          getTitle: (index, angle) => RadarChartTitle(
            text: index >= 0 && index < _titles.length ? _titles[index] : '',
          ),
          titleTextStyle: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          titlePositionPercentageOffset: 0.12,
          tickCount: 4,
          // Échelle 0→1 imposée : les ticks ne doivent pas s'auto-redimensionner.
          ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
          tickBorderData: BorderSide(color: Colors.grey.shade200, width: 0.5),
          gridBorderData: BorderSide(color: Colors.grey.shade300, width: 1),
          radarBorderData: BorderSide(color: Colors.grey.shade300, width: 1),
          radarBackgroundColor: Colors.transparent,
          radarTouchData: RadarTouchData(enabled: false),
        ),
      ),
    );
  }
}
