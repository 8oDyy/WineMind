import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onScan;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onScan,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Barre du bas
        BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: const Color(0xFF7B1A2E),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wine_bar),
              label: 'Vins',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: 'Ma cave',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: '',
            ),
          ],
        ),

        // Bouton caméra central surélevé
        Positioned(
          top: -25,
          child: GestureDetector(
            onTap: onScan,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF7B1A2E),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Color(0xFF7B1A2E),
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }
}