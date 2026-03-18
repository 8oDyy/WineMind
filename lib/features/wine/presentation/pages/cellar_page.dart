import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/wine.dart';
import '../bloc/cellar_bloc.dart';
import '../bloc/cellar_event.dart';
import '../bloc/cellar_state.dart';
import '../widgets/wine_cellar_card.dart';

class CellarPage extends StatefulWidget {
  const CellarPage({super.key});

  @override
  State<CellarPage> createState() => _CellarPageState();
}

class _CellarPageState extends State<CellarPage> {
  final TextEditingController _searchController = TextEditingController();
  static const List<String> _types = [
    'Tous',
    'Rouge',
    'Blanc',
    'Rosé',
    'Champagne',
  ];

  @override
  void initState() {
    super.initState();
    context.read<CellarBloc>().add(const LoadCellarEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<CellarBloc, CellarState>(
        builder: (context, state) {
          final isLoaded = state is CellarLoaded;
          final wines = isLoaded ? state.filteredWines : <Wine>[];
          final allWines = isLoaded ? state.allWines : <Wine>[];
          final selectedType = isLoaded ? state.selectedType : 'Tous';
          final totalStock = allWines.fold<int>(0, (sum, w) => sum + w.stock);

          return Column(
            children: [
              _buildHeader(context, totalStock),
              Expanded(
                child: state is CellarLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryWine,
                        ),
                      )
                    : state is CellarError
                        ? Center(
                            child: Text(
                              state.message,
                              style: const TextStyle(color: Colors.red),
                            ),
                          )
                        : CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: _buildSearchBar(context),
                              ),
                              SliverToBoxAdapter(
                                child: _buildTypeFilters(
                                  context,
                                  selectedType,
                                ),
                              ),
                              wines.isEmpty
                                  ? const SliverFillRemaining(
                                      child: Center(
                                        child: Text(
                                          'Aucun vin trouvé',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    )
                                  : SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) => WineCellarCard(
                                          wine: wines[index],
                                        ),
                                        childCount: wines.length,
                                      ),
                                    ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 16),
                              ),
                            ],
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int totalStock) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryWine,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ma Cave',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Gérez votre collection privée',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'INVENTAIRE',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white60,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '$totalStock ',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const TextSpan(
                                  text: 'Bouteilles',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<CellarBloc>().add(SearchWinesEvent(value));
        },
        decoration: InputDecoration(
          hintText: 'Rechercher un vin...',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primaryWine,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilters(BuildContext context, String selectedType) {
    return SizedBox(
      height: 37,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _types.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final type = _types[index];
          final isSelected = type == selectedType;
          return GestureDetector(
            onTap: () {
              context
                  .read<CellarBloc>()
                  .add(FilterWinesByTypeEvent(type));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryWine : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primaryWine : Colors.grey.shade300,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  height: 1.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
