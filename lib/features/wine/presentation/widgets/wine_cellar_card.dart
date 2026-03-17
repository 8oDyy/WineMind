import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/wine.dart';
import '../../domain/usecases/update_wine_stock.dart';
import '../bloc/wine_detail_bloc.dart';
import '../helpers/wine_type_color.dart';
import '../pages/wine_detail_page.dart';

class WineCellarCard extends StatelessWidget {
  final Wine wine;

  const WineCellarCard({super.key, required this.wine});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => WineDetailBloc(
              wine: wine,
              updateWineStock: GetIt.instance<UpdateWineStock>(),
            ),
            child: const WineDetailPage(),
          ),
        ),
      ),
      child: Container(
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
                      backgroundColor: wineTypeColor(wine.type),
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
      ),
    );
  }
}
