import '../../../../core/error/exceptions.dart';
import '../models/wine_model.dart';

abstract class WineLocalDataSource {
  Future<WineModel> getLastWine();
  Future<List<WineModel>> getAllWines();
  Future<WineModel> updateWineStock(String wineName, int newStock);
}

class WineLocalDataSourceImpl implements WineLocalDataSource {
  late final List<Map<String, dynamic>> _wines;

  WineLocalDataSourceImpl() {
    _wines = _initialWines.map((w) => Map<String, dynamic>.from(w)).toList();
  }

  static const List<Map<String, dynamic>> _initialWines = [
    {
      'name': 'Château Margaux',
      'year': '2015',
      'type': 'Rouge',
      'region': 'Bordeaux, France',
      'subRegion': 'Margaux, Bordeaux',
      'rating': 3.5,
      'points': 95,
      'apogee': '2025 - 2045',
      'stock': 3,
      'classification': 'PREMIER GRAND CRU CLASSÉ',
      'alcohol': 13.5,
      'grapes': ['Cab. Sauv', 'Merlot', 'Petit Verdot'],
      'location': 'Casier A-12',
      'foodPairings': ['Viandes', 'Gibier', 'Fromage'],
      'bodyLevel': 0.85,
      'tanninLevel': 0.80,
      'fruitLevel': 0.70,
    },
    {
      'name': 'Domaine de la Romanée-Conti',
      'year': '2018',
      'type': 'Rouge',
      'region': 'Bourgogne, France',
      'subRegion': 'Vosne-Romanée, Bourgogne',
      'rating': 5.0,
      'points': 99,
      'apogee': '2028 - 2060',
      'stock': 1,
      'classification': 'GRAND CRU',
      'alcohol': 13.0,
      'grapes': ['Pinot Noir'],
      'location': 'Casier B-01',
      'foodPairings': ['Viandes', 'Fromage'],
      'bodyLevel': 0.75,
      'tanninLevel': 0.65,
      'fruitLevel': 0.90,
    },
    {
      'name': 'Domaine Ott',
      'year': '2021',
      'type': 'Rosé',
      'region': 'Provence, France',
      'subRegion': 'Côtes de Provence',
      'rating': 4.0,
      'points': 89,
      'apogee': 'À boire maintenant',
      'stock': 12,
      'alcohol': 13.0,
      'grapes': ['Grenache', 'Cinsault', 'Tibouren'],
      'location': 'Casier C-04',
      'foodPairings': ['Poisson', 'Fruits de mer', 'Salade'],
      'bodyLevel': 0.40,
      'tanninLevel': 0.15,
      'fruitLevel': 0.75,
    },
    {
      'name': 'Puligny-Montrachet',
      'year': '2019',
      'type': 'Blanc',
      'region': 'Bourgogne, France',
      'subRegion': 'Côte de Beaune, Bourgogne',
      'rating': 4.5,
      'points': 93,
      'apogee': '2022 - 2030',
      'stock': 5,
      'classification': 'PREMIER CRU',
      'alcohol': 13.5,
      'grapes': ['Chardonnay'],
      'location': 'Casier D-07',
      'foodPairings': ['Poisson', 'Fruits de mer', 'Volaille'],
      'bodyLevel': 0.60,
      'tanninLevel': 0.10,
      'fruitLevel': 0.65,
    },
    {
      'name': 'Krug Grande Cuvée',
      'year': 'NV',
      'type': 'Champagne',
      'region': 'Champagne, France',
      'subRegion': 'Reims, Champagne',
      'rating': 5.0,
      'points': 97,
      'apogee': 'À boire maintenant',
      'stock': 2,
      'classification': 'PRESTIGE CUVÉE',
      'alcohol': 12.0,
      'grapes': ['Pinot Noir', 'Chardonnay', 'Meunier'],
      'location': 'Casier E-02',
      'foodPairings': ['Fruits de mer', 'Volaille', 'Fromage'],
      'bodyLevel': 0.55,
      'tanninLevel': 0.05,
      'fruitLevel': 0.80,
    },
    {
      'name': 'Château Pichon Baron',
      'year': '2016',
      'type': 'Rouge',
      'region': 'Bordeaux, France',
      'subRegion': 'Pauillac, Bordeaux',
      'rating': 4.0,
      'points': 94,
      'apogee': '2026 - 2050',
      'stock': 6,
      'classification': 'DEUXIÈME GRAND CRU CLASSÉ',
      'alcohol': 13.5,
      'grapes': ['Cab. Sauv', 'Merlot'],
      'location': 'Casier A-08',
      'foodPairings': ['Viandes', 'Gibier'],
      'bodyLevel': 0.80,
      'tanninLevel': 0.85,
      'fruitLevel': 0.65,
    },
    {
      'name': 'Sancerre Henri Bourgeois',
      'year': '2022',
      'type': 'Blanc',
      'region': 'Loire, France',
      'subRegion': 'Sancerre, Loire',
      'rating': 3.5,
      'points': 88,
      'apogee': '2023 - 2026',
      'stock': 8,
      'alcohol': 13.0,
      'grapes': ['Sauvignon Blanc'],
      'location': 'Casier D-11',
      'foodPairings': ['Fromage', 'Poisson', 'Salade'],
      'bodyLevel': 0.45,
      'tanninLevel': 0.05,
      'fruitLevel': 0.70,
    },
    {
      'name': 'Whispering Angel',
      'year': '2022',
      'type': 'Rosé',
      'region': 'Provence, France',
      'subRegion': 'Côtes de Provence',
      'rating': 3.5,
      'points': 87,
      'apogee': 'À boire maintenant',
      'stock': 18,
      'alcohol': 13.0,
      'grapes': ['Grenache', 'Cinsault', 'Vermentino'],
      'location': 'Casier C-09',
      'foodPairings': ['Poisson', 'Salade'],
      'bodyLevel': 0.35,
      'tanninLevel': 0.10,
      'fruitLevel': 0.80,
    },
  ];

  @override
  Future<WineModel> getLastWine() async {
    try {
      return WineModel.fromJson(_wines.first);
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<List<WineModel>> getAllWines() async {
    try {
      return _wines.map((json) => WineModel.fromJson(json)).toList();
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<WineModel> updateWineStock(String wineName, int newStock) async {
    try {
      final index = _wines.indexWhere((w) => w['name'] == wineName);
      if (index == -1) throw CacheException();
      _wines[index]['stock'] = newStock;
      return WineModel.fromJson(_wines[index]);
    } catch (_) {
      throw CacheException();
    }
  }
}
