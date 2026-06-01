import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/discovery_bloc.dart';
import '../bloc/discovery_event.dart';
import '../bloc/discovery_state.dart';
import '../widgets/discovery_category_row.dart';

/// Page « Découvertes » (onglet 2 du MainScreen) : recommandations de vins
/// organisées en catégories (carrousels horizontaux). Tap sur un vin → fiche
/// détail existante. Le `DiscoveryBloc` est fourni par le parent
/// (`BlocProvider` dans MainScreen).
class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  State<DiscoveryPage> createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  @override
  void initState() {
    super.initState();
    context.read<DiscoveryBloc>().add(const LoadDiscoveryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryWine,
        title: const Text(
          'Découvertes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<DiscoveryBloc, DiscoveryState>(
        builder: (context, state) {
          if (state is DiscoveryLoaded) {
            if (state.categories.isEmpty) return _buildEmpty();
            return _buildContent(state);
          }
          if (state is DiscoveryError) {
            return _buildError(context, state.message);
          }
          // DiscoveryInitial / DiscoveryLoading → squelette de chargement.
          return _buildSkeleton();
        },
      ),
    );
  }

  Widget _buildContent(DiscoveryLoaded state) {
    return RefreshIndicator(
      color: AppColors.primaryWine,
      onRefresh: () async {
        context.read<DiscoveryBloc>().add(const LoadDiscoveryEvent());
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: state.categories.length,
        separatorBuilder: (context, index) => const SizedBox(height: 24),
        itemBuilder: (context, index) =>
            DiscoveryCategoryRow(category: state.categories[index]),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_off, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Aucune découverte pour le moment.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<DiscoveryBloc>().add(const LoadDiscoveryEvent()),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Réessayer',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryWine,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Squelette : deux rangées factices (titre gris + cartes vides) pendant le
  /// chargement, pour matcher la structure finale et éviter un saut de layout.
  Widget _buildSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 20),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) => _buildSkeletonRow(),
    );
  }

  Widget _buildSkeletonRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            width: 160,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3,
            itemBuilder: (context, index) => Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
