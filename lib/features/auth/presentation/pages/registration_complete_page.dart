import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_colors.dart';
import '../../../../app.dart';
// import '../widgets/bubble_painter.dart';

class RegistrationCompletePage extends StatefulWidget {
  const RegistrationCompletePage({super.key});

  @override
  State<RegistrationCompletePage> createState() =>
      _RegistrationCompletePageState();
}

class _RegistrationCompletePageState extends State<RegistrationCompletePage>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();

    _particles = _ConfettiParticle.generate(200);

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..forward();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );
    _scaleController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Inscription terminée",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Partie haute : Paul + bulle ──
            Container(
              width: double.infinity,
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/img/Paul_Happy.png', height: 110),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "PAUL",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryWine,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryWine,
                              width: 1.5,
                            ),
                          ),
                          child: const Text(
                            "Merci pour votre inscription 🎉\nVotre profil est maintenant configuré.",
                            style: TextStyle(fontSize: 14, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Partie centrale : animation confetti + icône ──
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _CirclesBgPainter(),
                    ),
                  ),
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _confettiController,
                      builder: (_, _) => CustomPaint(
                        painter: _ConfettiPainter(
                          progress: _confettiController.value,
                          particles: _particles,
                        ),
                      ),
                    ),
                  ),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryWine,
                      ),
                      child: const Icon(
                        Icons.celebration_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Partie basse : texte + barre + bouton ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  const Text(
                    "Félicitations !",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Votre profil de dégustation est 100% prêt.",
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Barre profil configuré
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: AppColors.primaryWine, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            "PROFIL CONFIGURÉ",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        "100%",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryWine,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 1.0,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primaryWine),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // ✅ Navigue vers MainScreen qui contient
                        // le BlocProvider via MultiBlocProvider dans App
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryWine,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Continuer vers l'application",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Cercles de fond ──────────────────────────────────────────────────────────
class _CirclesBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[100]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width * 0.35, paint);
    canvas.drawCircle(center, size.width * 0.45, paint);
    canvas.drawCircle(center, size.width * 0.55, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Confettis ────────────────────────────────────────────────────────────────

enum _ConfettiShape { rect, ribbon, circle, triangle }

class _ConfettiParticle {
  final double vx;      // vélocité horizontale (pixels/sec normalisé)
  final double vy;      // vélocité verticale initiale (négatif = vers le haut)
  final double spin;    // vitesse de rotation
  final double wobbleAmp;
  final double wobbleFreq;
  final double size;
  final Color color;
  final _ConfettiShape shape;
  final double delay;   // 0..0.15s de décalage pour un effet staggered

  const _ConfettiParticle({
    required this.vx,
    required this.vy,
    required this.spin,
    required this.wobbleAmp,
    required this.wobbleFreq,
    required this.size,
    required this.color,
    required this.shape,
    required this.delay,
  });

  static const List<Color> _palette = [
    AppColors.primaryWine,
    Color(0xFFFF1744),
    Color(0xFFFFD600),
    Color(0xFFFF6D00),
    Color(0xFF00E676),
    Color(0xFF2979FF),
    Color(0xFFE040FB),
    Color(0xFF00E5FF),
    Color(0xFFFF4081),
    Color(0xFFFFFF00),
    Color(0xFF76FF03),
    Color(0xFFFF3D00),
  ];

  static List<_ConfettiParticle> generate(int count) {
    final rng = math.Random();
    final shapes = _ConfettiShape.values;
    return List.generate(count, (i) {
      // Éventail horizontal large, poussée verticale forte vers le HAUT
      final spreadX = (rng.nextDouble() - 0.5) * 2.0; // -1..1
      final upForce = -0.6 - rng.nextDouble() * 0.9;   // -0.6..-1.5 (vers le haut)
      return _ConfettiParticle(
        vx: spreadX * 600,
        vy: upForce * 900,
        spin: (rng.nextDouble() - 0.5) * 15,
        wobbleAmp: 10 + rng.nextDouble() * 30,
        wobbleFreq: 2 + rng.nextDouble() * 5,
        size: 6 + rng.nextDouble() * 10,
        color: _palette[i % _palette.length],
        shape: shapes[i % shapes.length],
        delay: rng.nextDouble() * 0.12,
      );
    });
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiParticle> particles;

  const _ConfettiPainter({
    required this.progress,
    required this.particles,
  });

  // Gravité en pixels/sec² (normalisé par la durée de l'animation)
  static const double _gravity = 2400;

  @override
  void paint(Canvas canvas, Size size) {
    // Point de départ : centre horizontal, milieu vertical
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;

    // Durée totale animation = 3 secondes
    const totalDuration = 3.0;

    for (final p in particles) {
      // Temps local de cette particule en secondes
      final tSec = (progress * totalDuration - p.delay * totalDuration)
          .clamp(0.0, totalDuration);
      if (tSec <= 0) continue;

      // Position physique : v*t + 0.5*g*t²
      final px = cx + p.vx * tSec + math.sin(tSec * p.wobbleFreq) * p.wobbleAmp;
      final py = cy + p.vy * tSec + 0.5 * _gravity * tSec * tSec;

      // Hors écran → skip
      if (px < -30 || px > size.width + 30 || py > size.height + 50 || py < -100) continue;

      // Fade out dans le dernier quart
      final double alpha;
      if (progress > 0.75) {
        alpha = (1.0 - (progress - 0.75) / 0.25).clamp(0.0, 1.0);
      } else {
        alpha = 1.0;
      }
      if (alpha <= 0) continue;

      final rot = tSec * p.spin;
      final paint = Paint()
        ..color = p.color.withAlpha((alpha * 255).round().clamp(0, 255));

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(rot);

      switch (p.shape) {
        case _ConfettiShape.rect:
          canvas.drawRect(
            Rect.fromCenter(
                center: Offset.zero, width: p.size, height: p.size * 0.45),
            paint,
          );
        case _ConfettiShape.ribbon:
          canvas.drawRect(
            Rect.fromCenter(
                center: Offset.zero,
                width: p.size * 2.0,
                height: p.size * 0.3),
            paint,
          );
        case _ConfettiShape.circle:
          canvas.drawCircle(Offset.zero, p.size * 0.4, paint);
        case _ConfettiShape.triangle:
          final path = Path()
            ..moveTo(0, -p.size * 0.55)
            ..lineTo(p.size * 0.5, p.size * 0.4)
            ..lineTo(-p.size * 0.5, p.size * 0.4)
            ..close();
          canvas.drawPath(path, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}