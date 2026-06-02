import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bubble_painter.dart';
import '../../../../core/widgets/glass.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'registration_complete_page.dart';

class ObjectivePage extends StatefulWidget {
  /// Niveau + préférences (chaîne "A, B") threadés depuis les étapes précédentes.
  /// L'objectif est choisi sur cet écran ; la persistance des 3 champs a lieu ici.
  final String niveau;
  final String preference;

  const ObjectivePage({
    super.key,
    required this.niveau,
    required this.preference,
  });

  @override
  State<ObjectivePage> createState() => _ObjectivePageState();
}

class _ObjectivePageState extends State<ObjectivePage> {
  int _selectedIndex = 0;

  final List<_ObjectiveOption> _options = const [
    _ObjectiveOption(
      title: "Trouver un vin",
      icon: Icons.search,
    ),
    _ObjectiveOption(
      title: "Découvrir",
      icon: Icons.explore_outlined,
    ),
    _ObjectiveOption(
      title: "Apprendre",
      icon: Icons.menu_book_outlined,
    ),
    _ObjectiveOption(
      title: "Gérer ma cave",
      icon: Icons.inventory_2_outlined,
    ),
  ];

  void _saveAndContinue(BuildContext context) {
    context.read<AuthBloc>().add(UpdateProfileEvent(
          niveau: widget.niveau,
          preference: widget.preference.isEmpty ? null : widget.preference,
          objectif: _options[_selectedIndex].title,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      // On n'écoute que les sous-états d'édition de profil pour piloter cet
      // écran ; les autres transitions auth ne nous concernent pas ici.
      listenWhen: (_, current) =>
          current is AuthProfileUpdateSuccess ||
          current is AuthProfileUpdateFailure,
      listener: (context, state) {
        if (state is AuthProfileUpdateSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RegistrationCompletePage(),
            ),
          );
        } else if (state is AuthProfileUpdateFailure) {
          // L'inscription ne doit pas être un cul-de-sac : on signale l'échec,
          // on laisse réessayer (bouton réactivé) et on propose de continuer
          // quand même — le profil pourra être complété plus tard.
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              glassSnackBar(
                "Impossible d'enregistrer votre profil pour le moment.",
                isError: true,
                duration: const Duration(seconds: 6),
                actionLabel: 'Continuer',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegistrationCompletePage(),
                    ),
                  );
                },
              ),
            );
        }
      },
      builder: (context, state) {
        final isSaving = state is AuthProfileUpdateInProgress;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const BackButton(color: Colors.black),
            title: const Text(
              "Objectif d'utilisation",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Bulle Paul ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Image.asset('assets/img/Paul_Happy.png', height: 70),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "PAUL",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryWine,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              CustomPaint(
                                painter: BubblePainter(),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  child: const Text(
                                    "Parfait. Dernière question. Qu'aimeriez-vous faire principalement avec WineMind ?",
                                    style:
                                        TextStyle(fontSize: 14, height: 1.4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Options ──
                    ...List.generate(_options.length, (index) {
                      final option = _options[index];
                      final isSelected = _selectedIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 18),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFDF2F3)
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryWine
                                    : Colors.grey[300]!,
                                width: isSelected ? 1.5 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  option.icon,
                                  size: 22,
                                  color: isSelected
                                      ? AppColors.primaryWine
                                      : Colors.grey[400],
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    option.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primaryWine
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                // Radio
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryWine
                                          : Colors.grey[300]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Center(
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.primaryWine,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // ── Barre de progression + bouton ──
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "PROGRESSION",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[500],
                          letterSpacing: 1,
                        ),
                      ),
                      const Text(
                        "Étape 3 sur 3",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryWine,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 3 / 3,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryWine,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          isSaving ? null : () => _saveAndContinue(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryWine,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            AppColors.primaryWine.withValues(alpha: 0.5),
                        disabledForegroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Continuer",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
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
      },
    );
  }
}

class _ObjectiveOption {
  final String title;
  final IconData icon;
  const _ObjectiveOption({required this.title, required this.icon});
}
