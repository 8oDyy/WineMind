import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/wine.dart';

class WineCellarCard extends StatelessWidget {
  final Wine wine;

  const WineCellarCard({super.key, required this.wine});

  Color _typeColor() {
    switch (wine.type) {
      case 'Rouge':
        return const Color(0xFF7B1A2E);
      case 'Blanc':
        return const Color(0xFFD4AC0D);
      case 'Rosé':
        return const Color(0xFFE8A0A0);
      case 'Champagne':
        return const Color(0xFFC5A028);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 72,
              height: 90,
              color: AppColors.cardAccent,
              child: const Icon(
                Icons.wine_bar,
                size: 36,
                color: AppColors.primaryWine,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${wine.name} ${wine.year}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 4,
                      backgroundColor: _typeColor(),
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        '${wine.type} • ${wine.region}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '(${wine.points} pts)',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  wine.apogee.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'STOCK',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primaryWine,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryWine,
                child: Text(
                  '${wine.stock}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
