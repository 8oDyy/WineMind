import '../../../../core/error/exceptions.dart';
import '../models/wine_model.dart';

abstract class WineLocalDataSource {
  Future<WineModel> getLastWine();
  Future<List<WineModel>> getAllWines();
}

class WineLocalDataSourceImpl implements WineLocalDataSource {
  static const List<Map<String, dynamic>> _mockWines = [
    {
      'name': 'Château Margaux',
      'year': '2015',
      'type': 'Rouge',
      'region': 'Bordeaux, France',
      'rating': 3.5,
      'points': 95,
      'apogee': '2025 - 2045',
      'stock': 3,
    },
    {
      'name': 'Domaine de la Romanée-Conti',
      'year': '2018',
      'type': 'Rouge',
      'region': 'Bourgogne, France',
      'rating': 5.0,
      'points': 99,
      'apogee': '2028 - 2060',
      'stock': 1,
    },
    {
      'name': 'Domaine Ott',
      'year': '2021',
      'type': 'Rosé',
      'region': 'Provence, France',
      'rating': 4.0,
      'points': 89,
      'apogee': 'À boire maintenant',
      'stock': 12,
    },
    {
      'name': 'Puligny-Montrachet',
      'year': '2019',
      'type': 'Blanc',
      'region': 'Bourgogne, France',
      'rating': 4.5,
      'points': 93,
      'apogee': '2022 - 2030',
      'stock': 5,
    },
    {
      'name': 'Krug Grande Cuvée',
      'year': 'NV',
      'type': 'Champagne',
      'region': 'Champagne, France',
      'rating': 5.0,
      'points': 97,
      'apogee': 'À boire maintenant',
      'stock': 2,
    },
    {
      'name': 'Château Pichon Baron',
      'year': '2016',
      'type': 'Rouge',
      'region': 'Bordeaux, France',
      'rating': 4.0,
      'points': 94,
      'apogee': '2026 - 2050',
      'stock': 6,
    },
    {
      'name': 'Sancerre Henri Bourgeois',
      'year': '2022',
      'type': 'Blanc',
      'region': 'Loire, France',
      'rating': 3.5,
      'points': 88,
      'apogee': '2023 - 2026',
      'stock': 8,
    },
    {
      'name': 'Whispering Angel',
      'year': '2022',
      'type': 'Rosé',
      'region': 'Provence, France',
      'rating': 3.5,
      'points': 87,
      'apogee': 'À boire maintenant',
      'stock': 18,
    },
  ];

  @override
  Future<WineModel> getLastWine() async {
    try {
      return WineModel.fromJson(_mockWines.first);
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<List<WineModel>> getAllWines() async {
    try {
      return _mockWines.map((json) => WineModel.fromJson(json)).toList();
    } catch (_) {
      throw CacheException();
    }
  }
}
