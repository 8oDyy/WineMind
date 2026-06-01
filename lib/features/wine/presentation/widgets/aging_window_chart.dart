import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Phase de garde d'un vin à un instant donné.
enum AgingPhase { young, peak, decline, past }

/// Graphique de fenêtre de garde (apogée) : une courbe en cloche
/// montée → pic → déclin, bornée par [drinkFrom] / [peakYear] / [drinkTo],
/// avec un marqueur vertical sur l'année courante.
///
/// N'afficher que si les bornes sont cohérentes (cf. [AgingWindowChart.isValid]).
class AgingWindowChart extends StatelessWidget {
  final int drinkFrom;
  final int peakYear;
  final int drinkTo;
  final int currentYear;

  const AgingWindowChart({
    super.key,
    required this.drinkFrom,
    required this.peakYear,
    required this.drinkTo,
    required this.currentYear,
  });

  /// Vrai si les 3 bornes existent et sont ordonnées de façon exploitable
  /// (`from <= peak <= to`, et fenêtre non dégénérée).
  static bool isValid(int? from, int? peak, int? to) {
    if (from == null || peak == null || to == null) return false;
    return from <= peak && peak <= to && from < to;
  }

  /// Phase courante d'après l'année [now] et les bornes.
  static AgingPhase phaseFor(int now, int from, int peak, int to) {
    if (now < from) return AgingPhase.young;
    if (now > to) return AgingPhase.past;
    // Dans la fenêtre : avant le pic = en train de s'ouvrir, après = décline.
    if (now < peak) return AgingPhase.young;
    if (now == peak) return AgingPhase.peak;
    return AgingPhase.decline;
  }

  AgingPhase get _phase => phaseFor(currentYear, drinkFrom, peakYear, drinkTo);

  String get _phaseLabel {
    switch (_phase) {
      case AgingPhase.young:
        return '🍇 Encore jeune';
      case AgingPhase.peak:
        return '🍷 À son apogée';
      case AgingPhase.decline:
        return '🍂 Sur le déclin';
      case AgingPhase.past:
        return '⌛ Passé son apogée';
    }
  }

  /// Couleur de phase : le **vert est réservé à l'apogée** (« bon moment »).
  /// Jeune/déclin = ambre/orange (attente), passé = rouge/gris.
  Color get _phaseColor {
    switch (_phase) {
      case AgingPhase.young:
        return const Color(0xFFE0A22B); // ambre (pas encore prêt)
      case AgingPhase.peak:
        return const Color(0xFF4CAF50); // vert (à son apogée)
      case AgingPhase.decline:
        return const Color(0xFFD98E2B); // orange (sur le déclin)
      case AgingPhase.past:
        return const Color(0xFFB0413E); // rouge sourd (passé)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _phaseLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _phaseColor,
              ),
            ),
            Text(
              '$currentYear',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          width: double.infinity,
          child: CustomPaint(
            painter: _AgingWindowPainter(
              drinkFrom: drinkFrom,
              peakYear: peakYear,
              drinkTo: drinkTo,
              currentYear: currentYear,
              markerColor: _phaseColor,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _bound('$drinkFrom', 'Début'),
            _bound('$peakYear', 'Apogée'),
            _bound('$drinkTo', 'Fin'),
          ],
        ),
      ],
    );
  }

  Widget _bound(String year, String label) {
    return Column(
      children: [
        Text(
          year,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}

class _AgingWindowPainter extends CustomPainter {
  final int drinkFrom;
  final int peakYear;
  final int drinkTo;
  final int currentYear;
  final Color markerColor;

  _AgingWindowPainter({
    required this.drinkFrom,
    required this.peakYear,
    required this.drinkTo,
    required this.currentYear,
    required this.markerColor,
  });

  /// Position horizontale [0,1] d'une année dans la fenêtre [from, to].
  double _xFor(int year) =>
      ((year - drinkFrom) / (drinkTo - drinkFrom)).clamp(0.0, 1.0);

  /// Couleurs du dégradé « feu tricolore » le long de l'axe temps.
  static const Color _young = Color(0xFFD64545); // rouge (trop jeune)
  static const Color _peak = Color(0xFF4CAF50); // vert (apogée)
  static const Color _decline = Color(0xFFD98E2B); // orange (déclin)

  /// Hauteur normalisée [0,1] de la cloche à la position horizontale [tx] (∈[0,1]).
  /// Cloche lisse et asymétrique : sommet = 1 au pic, base = 0 aux bornes,
  /// transition en cosinus surélevé (smooth) de chaque côté du pic.
  double _bellHeight(double tx, double peakT) {
    if (tx <= 0 || tx >= 1) return 0;
    // Progression [0,1] depuis la borne vers le pic, par côté.
    final double p = tx <= peakT
        ? (peakT <= 0 ? 1.0 : tx / peakT) // montée gauche
        : (peakT >= 1 ? 1.0 : (1 - tx) / (1 - peakT)); // descente droite
    // Raised-cosine : 0 à la borne, 1 au pic, dérivée nulle aux extrémités.
    return 0.5 - 0.5 * math.cos(p.clamp(0.0, 1.0) * math.pi);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const topPad = 6.0;
    const bottomPad = 2.0;
    final baseY = h - bottomPad;
    final usableH = baseY - topPad;

    final peakT = _xFor(peakYear);

    // Échantillonnage de la cloche lisse en N points.
    const steps = 64;
    final points = <Offset>[];
    for (var i = 0; i <= steps; i++) {
      final tx = i / steps;
      final y = baseY - _bellHeight(tx, peakT) * usableH;
      points.add(Offset(tx * w, y));
    }

    final curve = Path()..moveTo(points.first.dx, points.first.dy);
    for (final pt in points.skip(1)) {
      curve.lineTo(pt.dx, pt.dy);
    }

    // Dégradé horizontal « feu tricolore » : rouge → vert (au pic) → orange.
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: const [_young, _peak, _decline],
      stops: [0.0, peakT.clamp(0.05, 0.95), 1.0],
    ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Remplissage doux sous la courbe : dégradé tricolore en faible opacité.
    final fillPath = Path.from(curve)
      ..lineTo(w, baseY)
      ..lineTo(0, baseY)
      ..close();
    canvas.saveLayer(Rect.fromLTWH(0, 0, w, h), Paint());
    canvas.drawPath(fillPath, Paint()..shader = gradient);
    // Atténue le remplissage pour rester discret derrière la courbe.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.62)
        ..blendMode = BlendMode.srcATop,
    );
    canvas.restore();

    // Trait de la courbe, même dégradé tricolore.
    canvas.drawPath(
      curve,
      Paint()
        ..shader = gradient
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Marqueur vertical = année courante, couleur de la phase courante.
    final markerX = _xFor(currentYear) * w;
    final markerPaint = Paint()
      ..color = markerColor
      ..strokeWidth = 2;
    canvas.drawLine(Offset(markerX, 0), Offset(markerX, baseY), markerPaint);
    canvas.drawCircle(Offset(markerX, topPad), 4, Paint()..color = markerColor);
  }

  @override
  bool shouldRepaint(covariant _AgingWindowPainter old) =>
      old.drinkFrom != drinkFrom ||
      old.peakYear != peakYear ||
      old.drinkTo != drinkTo ||
      old.currentYear != currentYear ||
      old.markerColor != markerColor;
}
