import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/wine.dart';
import '../bloc/wine_detail_bloc.dart';
import '../bloc/wine_detail_event.dart';
import '../bloc/wine_detail_state.dart';
import '../helpers/wine_type_color.dart';

class WineDetailPage extends StatelessWidget {
  const WineDetailPage({super.key});

  static IconData _foodIcon(String pairing) {
    switch (pairing) {
      case 'Viandes':
        return Icons.restaurant;
      case 'Gibier':
        return Icons.forest;
      case 'Fromage':
        return Icons.lunch_dining;
      case 'Poisson':
        return Icons.set_meal;
      case 'Fruits de mer':
        return Icons.water;
      case 'Volaille':
        return Icons.egg_alt;
      case 'Salade':
        return Icons.eco;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WineDetailBloc, WineDetailState>(
      builder: (context, state) {
        if (state is WineDetailLoaded) {
          return _buildContent(context, state.wine);
        }
        if (state is WineDetailError) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(backgroundColor: AppColors.primaryWine),
            body: Center(child: Text(state.message)),
          );
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, Wine wine) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildHeader(context, wine),
                SliverToBoxAdapter(
                  child: _buildBody(context, wine),
                ),
              ],
            ),
          ),
          _buildBottomActions(context, wine),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Wine wine) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.primaryWine,
      leading: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      title: Text(
        '${wine.name} ${wine.year}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppColors.primaryWine),
            Center(
              child: Icon(
                Icons.wine_bar,
                size: 120,
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.primaryWine.withValues(alpha: 0.6),
                    AppColors.primaryWine,
                  ],
                  stops: const [0.4, 0.75, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (wine.designation != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2ECC71),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        wine.designation!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    '${wine.name}\n${wine.year}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  if (wine.winery != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      wine.winery!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Wine wine) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTags(wine),
          const SizedBox(height: 16),
          if (wine.description != null && wine.description!.isNotEmpty) ...[
            _buildDescriptionCard(wine),
            const SizedBox(height: 16),
          ],
          _buildTechnicalCard(wine),
          const SizedBox(height: 16),
          _buildTasteProfile(wine),
          const SizedBox(height: 16),
          _buildFoodPairings(wine),
          const SizedBox(height: 16),
          _buildStockManagement(context, wine),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTags(Wine wine) {
    return Wrap(
      spacing: 8,
      children: [
        _buildChip(
          icon: Icons.location_on,
          label: wine.region,
          color: Colors.grey.shade700,
        ),
        _buildChip(
          icon: Icons.wine_bar,
          label: wine.type,
          color: wineTypeColor(wine.type),
        ),
      ],
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(Wine wine) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DESCRIPTION',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            wine.description!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalCard(Wine wine) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTechColumn(
                  label: 'CÉPAGE',
                  value: wine.variety ?? '-',
                ),
              ),
              Container(width: 1, height: 60, color: Colors.grey.shade100),
              Expanded(
                child: _buildTechColumn(
                  label: 'DOMAINE',
                  value: wine.winery ?? '-',
                ),
              ),
            ],
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          Row(
            children: [
              Expanded(
                child: _buildTechColumn(
                  label: 'PAYS',
                  value: wine.country ?? '-',
                ),
              ),
              Container(width: 1, height: 60, color: Colors.grey.shade100),
              Expanded(
                child: _buildTechColumn(
                  label: 'PRIX',
                  value: wine.price != null ? '${wine.price!.toStringAsFixed(0)} €' : '-',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechColumn({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasteProfile(Wine wine) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROFIL GUSTATIF',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 14),
          _buildProfileBar('Corps', wine.bodyLevel),
          const SizedBox(height: 10),
          _buildProfileBar('Tanins', wine.tanninLevel),
          const SizedBox(height: 10),
          _buildProfileBar('Fruit', wine.fruitLevel),
        ],
      ),
    );
  }

  Widget _buildProfileBar(String label, double level) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: level,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryWine,
              ),
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodPairings(Wine wine) {
    if (wine.foodPairings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'ACCORDS METS',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: wine.foodPairings
              .take(4)
              .map((pairing) => _buildFoodIcon(pairing))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildFoodIcon(String pairing) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.cardAccent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _foodIcon(pairing),
              color: AppColors.primaryWine,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pairing.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _updateStock(BuildContext context, Wine wine, int delta) {
    final newStock = wine.stock + delta;
    if (newStock < 0 || wine.cellarId == null) return;
    context.read<WineDetailBloc>().add(
      UpdateStockEvent(cellarId: wine.cellarId!, newStock: newStock),
    );
  }

  Widget _buildStockManagement(BuildContext context, Wine wine) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gestion du Stock',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (wine.location != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Emplacement: ${wine.location}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Row(
            children: [
              _buildStockButton(
                icon: Icons.remove,
                onTap: () => _updateStock(context, wine, -1),
              ),
              Container(
                width: 40,
                alignment: Alignment.center,
                child: Text(
                  '${wine.stock}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _buildStockButton(
                icon: Icons.add,
                onTap: () => _updateStock(context, wine, 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.primaryWine),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, Wine wine) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _updateStock(context, wine, -1),
              icon: const Icon(Icons.wine_bar, color: Colors.white),
              label: const Text(
                'Ouvrir une bouteille',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryWine,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.edit_note,
                color: AppColors.primaryWine,
              ),
              label: const Text(
                'Ajouter une note personnelle',
                style: TextStyle(
                  color: AppColors.primaryWine,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primaryWine),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
