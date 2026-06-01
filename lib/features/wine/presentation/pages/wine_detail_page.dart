import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/wine.dart';
import '../bloc/wine_detail_bloc.dart';
import '../bloc/wine_detail_event.dart';
import '../bloc/wine_detail_state.dart';
import '../helpers/wine_type_color.dart';
import '../widgets/aging_window_chart.dart';
import '../widgets/taste_profile_radar.dart';

class WineDetailPage extends StatelessWidget {
  /// Année courante utilisée par le graphique d'apogée. Optionnelle pour
  /// permettre l'injection en test ; à défaut, l'année système est utilisée.
  final int? currentYear;

  const WineDetailPage({super.key, this.currentYear});

  int get _resolvedYear => currentYear ?? DateTime.now().year;

  /// Normalise un libellé d'accord pour un matching tolérant (insensible à la
  /// casse, aux accents et au pluriel) entre la donnée brute et nos icônes.
  static String _normalizePairing(String pairing) {
    var s = pairing.toLowerCase().trim();
    const accents = {
      'à': 'a', 'â': 'a', 'ä': 'a',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'î': 'i', 'ï': 'i',
      'ô': 'o', 'ö': 'o',
      'û': 'u', 'ù': 'u', 'ü': 'u',
      'ç': 'c',
    };
    accents.forEach((k, v) => s = s.replaceAll(k, v));
    if (s.endsWith('s')) s = s.substring(0, s.length - 1);
    return s;
  }

  static IconData _foodIcon(String pairing) {
    switch (_normalizePairing(pairing)) {
      case 'viande':
        return Icons.restaurant;
      case 'gibier':
        return Icons.forest;
      case 'fromage':
        return Icons.lunch_dining;
      case 'poisson':
        return Icons.set_meal;
      case 'fruit de mer': // "fruits de mer" → "fruit de mer" après dé-pluralisation
      case 'fruits de mer':
        return Icons.water;
      case 'volaille':
        return Icons.egg_alt;
      case 'salade':
        return Icons.eco;
      case 'dessert':
        return Icons.cake;
      case 'apéritif':
      case 'aperitif':
        return Icons.local_bar;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WineDetailBloc, WineDetailState>(
      listenWhen: (prev, curr) =>
          curr is WineDetailLoaded &&
          (curr.enrichmentFailed ||
              curr.addToCellarError != null ||
              (curr.addedToCellar &&
                  (prev is! WineDetailLoaded || !prev.addedToCellar))),
      listener: (context, state) {
        if (state is! WineDetailLoaded) return;
        final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();

        if (state.enrichmentFailed) {
          messenger.showSnackBar(
            SnackBar(
              content: const Text('Échec de la génération du profil.'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Réessayer',
                onPressed: () => context
                    .read<WineDetailBloc>()
                    .add(const EnrichWineEvent()),
              ),
            ),
          );
        } else if (state.addToCellarError != null) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(state.addToCellarError!),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Réessayer',
                onPressed: () => context
                    .read<WineDetailBloc>()
                    .add(const AddToCellarEvent()),
              ),
            ),
          );
        } else if (state.addedToCellar) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Vin ajouté à votre cave.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is WineDetailLoaded) {
          return _buildContent(context, state);
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

  Widget _buildContent(BuildContext context, WineDetailLoaded state) {
    final wine = state.wine;
    // Contexte « Découvertes » : un vin issu d'une reco n'a pas de cellarId.
    // On masque alors la gestion de stock / « Ouvrir une bouteille » et on
    // propose à la place un CTA « Ajouter à ma cave ».
    final isInCellar = wine.cellarId != null;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildHeader(context, wine),
                SliverToBoxAdapter(
                  child: _buildBody(context, wine, state.isEnriching, isInCellar),
                ),
              ],
            ),
          ),
          _buildBottomActions(context, state, isInCellar),
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

  Widget _buildBody(
    BuildContext context,
    Wine wine,
    bool isEnriching,
    bool isInCellar,
  ) {
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
          // Pendant la génération IA : un seul bandeau de loading couvre les
          // sections enrichies (radar / apogée / accords).
          if (isEnriching) ...[
            _buildEnrichingPlaceholder(),
            const SizedBox(height: 16),
          ] else ...[
            _buildTasteProfile(wine),
            const SizedBox(height: 16),
            if (AgingWindowChart.isValid(
                  wine.drinkFrom,
                  wine.peakYear,
                  wine.drinkTo,
                ) ||
                wine.apogee.trim().isNotEmpty) ...[
              _buildAgingWindow(wine),
              const SizedBox(height: 16),
            ],
            _buildFoodPairings(wine),
            const SizedBox(height: 16),
          ],
          // Gestion de stock seulement pour un vin déjà en cave.
          if (isInCellar) ...[
            _buildStockManagement(context, wine),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildEnrichingPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
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
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.primaryWine),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Génération du profil…',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Profil gustatif, accords et fenêtre de garde',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
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
          const SizedBox(height: 8),
          if (TasteProfileRadar.canRender(
            wine.bodyLevel,
            wine.tanninLevel,
            wine.fruitLevel,
          ))
            TasteProfileRadar(
              bodyLevel: wine.bodyLevel!,
              tanninLevel: wine.tanninLevel!,
              fruitLevel: wine.fruitLevel!,
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Profil gustatif non disponible pour ce vin.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAgingWindow(Wine wine) {
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
            'FENÊTRE DE GARDE',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          // Graphe numérique : seulement si la fenêtre de garde structurée est
          // disponible (drink_from/peak_year/drink_to).
          if (AgingWindowChart.isValid(
            wine.drinkFrom,
            wine.peakYear,
            wine.drinkTo,
          )) ...[
            const SizedBox(height: 12),
            AgingWindowChart(
              drinkFrom: wine.drinkFrom!,
              peakYear: wine.peakYear!,
              drinkTo: wine.drinkTo!,
              currentYear: _resolvedYear,
            ),
          ],
          // Note d'apogée saisie par l'utilisateur (texte libre), affichée en
          // complément du graphique numérique quand elle est renseignée
          // (priorité à la donnée utilisateur sur l'IA).
          if (wine.apogee.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.sticky_note_2_outlined,
                    size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    wine.apogee,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Construit une énumération française lisible des accords
  /// (ex. "Viandes, Gibier et Fromage").
  static String _pairingsSentence(List<String> pairings) {
    if (pairings.isEmpty) return '';
    if (pairings.length == 1) return pairings.first;
    final head = pairings.sublist(0, pairings.length - 1).join(', ');
    return '$head et ${pairings.last}';
  }

  Widget _buildFoodPairings(Wine wine) {
    // Cas vin custom / sans accords : on n'affiche rien.
    if (wine.foodPairings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
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
        // Annotation lisible (en plus des icônes).
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'Ce vin se marie bien avec '),
                TextSpan(
                  text: _pairingsSentence(wine.foodPairings),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: wine.foodPairings
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

  Widget _buildBottomActions(
    BuildContext context,
    WineDetailLoaded state,
    bool isInCellar,
  ) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: isInCellar
            ? _cellarActions(context, state.wine)
            : _discoveryActions(context, state),
      ),
    );
  }

  /// Actions pour un vin déjà en cave : ouvrir une bouteille + note perso.
  List<Widget> _cellarActions(BuildContext context, Wine wine) {
    return [
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
    ];
  }

  /// Action pour un vin issu d'une reco (Découvertes) : ajout à la cave.
  List<Widget> _discoveryActions(BuildContext context, WineDetailLoaded state) {
    final added = state.addedToCellar;
    final loading = state.isAddingToCellar;
    return [
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: (added || loading)
              ? null
              : () =>
                  context.read<WineDetailBloc>().add(const AddToCellarEvent()),
          icon: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  added ? Icons.check : Icons.add,
                  color: Colors.white,
                ),
          label: Text(
            added ? 'Ajouté à ma cave' : 'Ajouter à ma cave',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryWine,
            disabledBackgroundColor:
                AppColors.primaryWine.withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
        ),
      ),
    ];
  }
}
