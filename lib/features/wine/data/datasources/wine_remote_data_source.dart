import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/wine_category_model.dart';
import '../models/wine_model.dart';

abstract class WineRemoteDataSource {
  /// Récupère tous les vins de la cave de l'utilisateur connecté.
  Future<List<WineModel>> getUserCellar();

  /// Récupère les recommandations Découvertes groupées par catégorie
  /// (`GET /api/discovery`, JWT). `limitPerCategory` borne le nombre de vins
  /// renvoyés par catégorie.
  Future<List<WineCategoryModel>> getDiscovery({int limitPerCategory});

  /// Récupère le dernier vin ajouté à la cave, ou null si cave vide.
  Future<WineModel?> getLastCellarWine();

  /// Ajoute un vin à la cave de l'utilisateur.
  Future<void> addToCellar(WineModel wine);

  /// Supprime un vin de la cave par son cellarId.
  Future<void> removeFromCellar(String cellarId);

  /// Met à jour le stock d'un vin dans la cave.
  Future<void> updateCellarStock(String cellarId, int stock);

  /// Déclenche l'enrichissement IA d'un vin catalogue (profil gustatif,
  /// accords, fenêtre de garde) et renvoie le vin enrichi.
  Future<WineModel> enrichWine(String wineId);
}

class WineRemoteDataSourceImpl implements WineRemoteDataSource {
  final http.Client client;
  final String baseUrl;
  final SupabaseClient supabase;

  WineRemoteDataSourceImpl({
    required this.client,
    required this.baseUrl,
    required this.supabase,
  });

  Map<String, String> get _headers {
    final token = supabase.auth.currentSession?.accessToken;
    if (token == null) throw const ServerException();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<List<WineModel>> getUserCellar() async {
    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/api/cellar'),
            headers: _headers,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw const ServerException(),
          );

      if (response.statusCode == 200) {
        return (jsonDecode(response.body) as List)
            .map((e) => WineModel.fromCellarJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw const ServerException();
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<WineCategoryModel>> getDiscovery({int limitPerCategory = 12}) async {
    try {
      final response = await client
          .get(
            Uri.parse(
              '$baseUrl/api/discovery?limit_per_category=$limitPerCategory',
            ),
            headers: _headers,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw const ServerException(),
          );

      if (response.statusCode == 200) {
        // Réponse : { "categories": [ { key, title, subtitle, wines:[...] } ] }.
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final categories = body['categories'] as List<dynamic>? ?? const [];
        return categories
            .map((e) =>
                WineCategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw const ServerException();
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<WineModel?> getLastCellarWine() async {
    try {
      final response = await client
          .get(
            Uri.parse('$baseUrl/api/cellar/last'),
            headers: _headers,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw const ServerException(),
          );

      if (response.statusCode == 200) {
        return WineModel.fromCellarJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw const ServerException();
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> addToCellar(WineModel wine) async {
    try {
      final response = await client
          .post(
            Uri.parse('$baseUrl/api/cellar'),
            headers: _headers,
            body: jsonEncode(wine.toCellarApiJson()),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw const ServerException(),
          );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw const ServerException();
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> removeFromCellar(String cellarId) async {
    try {
      final response = await client
          .delete(
            Uri.parse('$baseUrl/api/cellar/$cellarId'),
            headers: _headers,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw const ServerException(),
          );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw const ServerException();
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateCellarStock(String cellarId, int stock) async {
    try {
      final response = await client
          .patch(
            Uri.parse('$baseUrl/api/cellar/$cellarId/stock'),
            headers: _headers,
            body: jsonEncode({'stock': stock}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw const ServerException(),
          );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw const ServerException();
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<WineModel> enrichWine(String wineId) async {
    try {
      final response = await client
          .post(
            Uri.parse('$baseUrl/api/wine/$wineId/enrich'),
            headers: _headers,
          )
          .timeout(
            // 1er appel = génération LLM (2–8 s, jusqu'à ~20 s) → marge à 30 s.
            const Duration(seconds: 30),
            onTimeout: () => throw const ServerException(),
          );

      if (response.statusCode == 200) {
        // Réponse enveloppée : { "enriched": bool, "wine": { <row wines> } }.
        // On parse `wine` (row catalogue brute, iso `fromCatalogJson`).
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final wineJson = body['wine'] as Map<String, dynamic>?;
        if (wineJson == null) throw const ServerException();
        return WineModel.fromCatalogJson(wineJson);
      } else {
        throw const ServerException();
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
