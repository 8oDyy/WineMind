import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/wine_category.dart';
import 'discovery_wine_card.dart';

/// Une rangée de la page Découvertes : titre/sous-titre de catégorie + un
/// carrousel horizontal de cartes vin.
class DiscoveryCategoryRow extends StatelessWidget {
  final WineCategory category;

  const DiscoveryCategoryRow({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    if (category.wines.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (category.subtitle != null &&
                  category.subtitle!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  category.subtitle!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: category.wines.length,
            itemBuilder: (context, index) =>
                DiscoveryWineCard(wine: category.wines[index]),
          ),
        ),
      ],
    );
  }
}
