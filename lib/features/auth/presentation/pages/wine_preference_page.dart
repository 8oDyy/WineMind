import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bubble_painter.dart';
import 'objective_page.dart';

class WinePreferencePage extends StatefulWidget {
  const WinePreferencePage({super.key});

  @override
  State<WinePreferencePage> createState() => _WinePreferencePageState();
}

class _WinePreferencePageState extends State<WinePreferencePage> {
  // ✅ Multi-sélection
  final Set<int> _selectedIndexes = {0};

  final List<_WineOption> _options = const [
    _WineOption(title: "Vin Rouge", icon: Icons.wine_bar),
    _WineOption(title: "Vin Rosé", icon: Icons.local_bar),
    _WineOption(title: "Vin Blanc", icon: Icons.emoji_food_beverage),
    _WineOption(title: "Vin Pétillant", icon: Icons.bubble_chart_outlined),
    _WineOption(title: "Pas de préférence", icon: Icons.block_outlined),
  ];

  void _toggle(int index) {
    setState(() {
      // "Pas de préférence" désélectionne tout le reste
      if (index == _options.length - 1) {
        _selectedIndexes.clear();
        _selectedIndexes.add(index);
      } else {
        // Désélectionne "Pas de préférence" si on choisit autre chose
        _selectedIndexes.remove(_options.length - 1);
        if (_selectedIndexes.contains(index)) {
          _selectedIndexes.remove(index);
        } else {
          _selectedIndexes.add(index);
        }
        if (_selectedIndexes.isEmpty) _selectedIndexes.add(index);
      }
    });
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
          "Préférences de vin",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                                    "Merci. Maintenant dites-moi quel types de vins vous préférez. Vous pouvez en choisir plusieurs !",
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

                    // ── Options multi-sélection ──
                    ...List.generate(_options.length, (index) {
                      final option = _options[index];
                      final isSelected = _selectedIndexes.contains(index);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => _toggle(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
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
                                // ✅ Checkbox ronde
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? AppColors.primaryWine
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryWine
                                          : Colors.grey[300]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check,
                                          size: 14, color: Colors.white)
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
                        "Étape 2 sur 3",
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
                      value: 2 / 3,
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ObjectivePage(),
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Continuer",
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

class _WineOption {
  final String title;
  final IconData icon;
  const _WineOption({required this.title, required this.icon});
}
