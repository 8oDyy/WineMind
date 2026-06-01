import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/wine.dart';
import '../../domain/usecases/add_wine_to_cellar.dart';
import '../../domain/usecases/enrich_wine.dart';
import '../../domain/usecases/update_wine_stock.dart';
import '../bloc/wine_detail_bloc.dart';
import '../bloc/wine_detail_event.dart';
import '../helpers/wine_type_color.dart';
import '../pages/wine_detail_page.dart';

/// Carte compacte d'un vin recommandé, affichée dans un carrousel horizontal de
/// la page Découvertes. Le tap ouvre la fiche détail existante
/// (`WineDetailPage`) avec son `WineDetailBloc`, qui déclenche l'enrichissement
/// IA à l'ouverture — exactement comme depuis la cave.
class DiscoveryWineCard extends StatelessWidget {
  final Wine wine;

  const DiscoveryWineCard({super.key, required this.wine});

  @override
  Widget build(BuildContext context) {
    final typeColor = wineTypeColor(wine.type);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => WineDetailBloc(
              wine: wine,
              updateWineStock: sl<UpdateWineStock>(),
              enrichWine: sl<EnrichWine>(),
              addWineToCellar: sl<AddWineToCellar>(),
            )..add(const EnrichWineEvent()),
            child: const WineDetailPage(),
          ),
        ),
      ),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visuel haut de carte : image du vin si disponible, sinon un aplat
            // teinté par le type avec une icône bouteille.
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: _buildVisual(typeColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wine.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (wine.year.isNotEmpty) wine.year,
                      if (wine.region.isNotEmpty) wine.region,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTypeChip(typeColor),
                      const Spacer(),
                      if (wine.price != null)
                        Text(
                          '${wine.price!.toStringAsFixed(0)} €',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryWine,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisual(Color typeColor) {
    final url = wine.imageUrl;
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _buildPlaceholder(typeColor),
      );
    }
    return _buildPlaceholder(typeColor);
  }

  Widget _buildPlaceholder(Color typeColor) {
    return Container(
      color: typeColor.withValues(alpha: 0.12),
      child: Center(
        child: Icon(
          Icons.wine_bar,
          size: 44,
          color: typeColor.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildTypeChip(Color typeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        wine.type,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: typeColor,
        ),
      ),
    );
  }
}
