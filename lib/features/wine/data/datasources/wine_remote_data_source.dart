import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/wine_model.dart';

abstract class WineRemoteDataSource {
  /// Récupère tous les vins de la cave de l'utilisateur connecté.
  Future<List<WineModel>> getUserCellar();

  /// Récupère le dernier vin ajouté à la cave, ou null si cave vide.
  Future<WineModel?> getLastCellarWine();

  /// Ajoute un vin à la cave de l'utilisateur.
  Future<void> addToCellar(WineModel wine);

  /// Supprime un vin de la cave par son cellarId.
  Future<void> removeFromCellar(String cellarId);

  /// Met à jour le stock d'un vin dans la cave.
  Future<void> updateCellarStock(String cellarId, int stock);
}

class WineRemoteDataSourceImpl implements WineRemoteDataSource {
  final SupabaseClient _client;

  WineRemoteDataSourceImpl(this._client);

  String get _userId {
    final user = _client.auth.currentUser;
    if (user == null) throw ServerException();
    return user.id;
  }

  @override
  Future<List<WineModel>> getUserCellar() async {
    try {
      final response = await _client
          .from('user_cellar')
          .select('*, wines(*)')
          .eq('user_id', _userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => WineModel.fromCellarJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<WineModel?> getLastCellarWine() async {
    try {
      final response = await _client
          .from('user_cellar')
          .select('*, wines(*)')
          .eq('user_id', _userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return WineModel.fromCellarJson(response);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> addToCellar(WineModel wine) async {
    try {
      await _client
          .from('user_cellar')
          .insert(wine.toCellarInsert(_userId));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> removeFromCellar(String cellarId) async {
    try {
      await _client
          .from('user_cellar')
          .delete()
          .eq('id', cellarId)
          .eq('user_id', _userId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateCellarStock(String cellarId, int stock) async {
    try {
      await _client
          .from('user_cellar')
          .update({'stock': stock})
          .eq('id', cellarId)
          .eq('user_id', _userId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
