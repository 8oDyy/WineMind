import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/wine.dart';
import '../../domain/usecases/enrich_wine.dart';
import '../../domain/usecases/update_wine_stock.dart';
import '../bloc/wine_detail_bloc.dart';
import '../bloc/wine_detail_event.dart';
import '../pages/wine_detail_page.dart';

class WineLastCard extends StatelessWidget {
  final Wine wine;

  const WineLastCard({super.key, required this.wine});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => WineDetailBloc(
              wine: wine,
              updateWineStock: sl<UpdateWineStock>(),
              enrichWine: sl<EnrichWine>(),
            )..add(const EnrichWineEvent()),
            child: const WineDetailPage(),
          ),
        ),
      ),
      child: Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dernier vin',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryWine,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 200,
              color: AppColors.cardAccent,
              child: const Icon(
                Icons.wine_bar,
                size: 100,
                color: AppColors.primaryWine,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${wine.name} ${wine.year}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const CircleAvatar(
                radius: 5,
                backgroundColor: AppColors.primaryWine,
              ),
              const SizedBox(width: 6),
              Text(
                '${wine.type} • ${wine.region}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < wine.rating.floor() ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '(${wine.points} pts)',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const Spacer(),
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
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primaryWine,
                    child: Text(
                      '${wine.stock}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'APOGÉE : ${wine.apogee}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      ),
    );
  }
}
