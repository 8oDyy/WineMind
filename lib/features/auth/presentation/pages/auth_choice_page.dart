import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bubble_painter.dart';
import 'create_account_page.dart';
import 'login_page.dart';

class AuthChoicePage extends StatelessWidget {
  const AuthChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 🔝 LOGO EN HAUT (SVG)
              SvgPicture.asset(
                'assets/img/logo-winemind.svg',
                height: 80,
              ),
              const SizedBox(height: 12),

              const Text(
                "WineMind",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text(
                "Votre sommelier digital",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 BULLE DE DISCUSSION AVEC PAUL
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Paul (PNG)
                  Image.asset(
                    'assets/img/Paul_Happy.png',
                    height: 60,
                  ),
                  const SizedBox(width: 10),

                  // Bulle de dialogue
                  Expanded(
                    child: CustomPaint(
                      painter: BubblePainter(),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: const Text(
                          "Bonjour et bienvenue sur WineMind 🍷\n\n"
                          "Je suis votre assistant pour trouver le vin parfait selon votre plat. "
                          "Vous pouvez simplement me décrire ce que vous mangez et je vous proposerai "
                          "un vin adapté, tout en vous expliquant pourquoi cet accord fonctionne.\n\n"
                          "Avant de commencer, j'ai besoin de créer votre profil.",
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // 🔻 BOUTONS EN BAS
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateAccountPage(),
                          ),
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
                      child: const Text("Créer un compte"),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Se connecter"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "L'abus d'alcool est dangereux pour la santé",
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
