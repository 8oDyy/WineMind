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
