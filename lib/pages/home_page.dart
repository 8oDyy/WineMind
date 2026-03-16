import 'package:flutter/material.dart';
import '../widgets/wine_last_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  'WineMind',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B1A2E),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              // Card dernier vin
              const WineCard(
                name: 'Château Margaux',
                year: '2015',
                type: 'Rouge',
                region: 'Bordeaux, France',
                rating: 3.5,
                points: 95,
                apogee: '2025 - 2045',
                stock: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}