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

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

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
                        painter: _ConfettiPainter(_confettiController.value),
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
class _ConfettiPainter extends CustomPainter {
  final double progress;
  static final _rng = math.Random(42);
  static final List<_ConfettiParticle> _particles =
      List.generate(30, (i) {
    return _ConfettiParticle(
      x: _rng.nextDouble(),
      startY: -0.1 - _rng.nextDouble() * 0.5,
      speed: 0.3 + _rng.nextDouble() * 0.4,
      size: 4 + _rng.nextDouble() * 6,
      color: i % 5 == 0
          ? AppColors.primaryWine
          : i % 5 == 1
              ? const Color(0xFFE8C4A0)
              : i % 5 == 2
                  ? const Color(0xFFF5E6D3)
                  : i % 5 == 3
                      ? const Color(0xFFD4A0A0)
                      : Colors.white,
      angle: _rng.nextDouble() * math.pi * 2,
      spin: (_rng.nextDouble() - 0.5) * 0.2,
    );
  });

  const _ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final y = (p.startY + progress * p.speed) % 1.2;
      final x = p.x + math.sin(progress * math.pi * 2 + p.angle) * 0.03;
      final angle = p.angle + progress * p.spin * math.pi * 2;
      final paint = Paint()..color = p.color;
      canvas.save();
      canvas.translate(x * size.width, y * size.height);
      canvas.rotate(angle);
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset.zero, width: p.size, height: p.size * 0.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _ConfettiParticle {
  final double x;
  final double startY;
  final double speed;
  final double size;
  final Color color;
  final double angle;
  final double spin;
  const _ConfettiParticle({
    required this.x,
    required this.startY,
    required this.speed,
    required this.size,
    required this.color,
    required this.angle,
    required this.spin,
  });
}