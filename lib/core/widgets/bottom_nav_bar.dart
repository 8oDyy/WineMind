import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// Barre de navigation iOS : pleine largeur, collée en bas, fond **blanc
/// translucide frosté** (`BackdropFilter`) avec une fine hairline en haut.
/// Item actif en bordeaux (icône + label), inactif en gris — **sans cercle
/// plein**. Feedback tap iOS (léger scale + haptique), **sans ripple/splash
/// Material**. API inchangée (`currentIndex` / `onTap`).
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = <_NavItem>[
    _NavItem(icon: Icons.home_rounded, label: 'Accueil'),
    _NavItem(icon: Icons.explore_rounded, label: 'Découvertes'),
    _NavItem(icon: Icons.store_rounded, label: 'Ma cave'),
    _NavItem(icon: Icons.settings_rounded, label: 'Paramètres'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            // Blanc franchement translucide : le flou laisse transparaître le
            // contenu, sans virer à la dalle opaque.
            color: Color(0xF2FFFFFF),
            border: Border(
              // Hairline supérieure (séparateur iOS).
              top: BorderSide(color: Color(0x1F000000), width: 0.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Expanded(
                      child: _NavBarButton(
                        item: _items[i],
                        selected: i == currentIndex,
                        onTap: () {
                          // Retour haptique léger iOS, seulement quand on change
                          // réellement d'onglet (pas de re-tap sur l'actif).
                          if (i != currentIndex) {
                            HapticFeedback.lightImpact();
                          }
                          onTap(i);
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}

/// Bouton d'onglet : pas de splash Material. Feedback iOS = léger scale au
/// pressed + couleur (bordeaux actif / gris inactif) animée.
class _NavBarButton extends StatefulWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavBarButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_NavBarButton> createState() => _NavBarButtonState();
}

class _NavBarButtonState extends State<_NavBarButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.selected
        ? AppColors.primaryWine
        : const Color(0xFF8E8E93); // gris iOS pour l'inactif

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.item.icon, size: 24, color: color),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight:
                      widget.selected ? FontWeight.w600 : FontWeight.w400,
                ),
                child: Text(widget.item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
