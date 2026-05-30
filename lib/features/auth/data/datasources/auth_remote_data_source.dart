import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> register({
    required String email,
    required String password,
    required String prenom,
    required String nom,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<void> updateProfile({
    required String userId,
    String? niveau,
    String? preference,
    String? objectif,
  });

  Future<void> deleteAccount({required String userId});
  UserModel? getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;
  final http.Client httpClient;
  final String baseUrl;

  AuthRemoteDataSourceImpl({
    required this.supabase,
    required this.httpClient,
    required this.baseUrl,
  });

  Map<String, String> get _headers {
    final token = supabase.auth.currentSession?.accessToken;
    if (token == null) throw Exception('Utilisateur non connecté');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String prenom,
    required String nom,
  }) async {
    // 1. SignUp — le trigger Supabase insère automatiquement dans profiles
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'prenom': prenom,
        'nom': nom,
        'full_name': '$prenom $nom',
      },
    );

    if (response.user == null) {
      throw Exception('Erreur lors de la création du compte');
    }

    // 2. Login pour obtenir une session active
    final loginResponse = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (loginResponse.user == null) {
      throw Exception(
        'Login échoué — vérifie que "Confirm email" est désactivé dans Supabase Auth settings',
      );
    }

    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('Utilisateur non connecté après login');
    }

    // ✅ Pas d'insert manuel — le trigger Supabase s'en charge automatiquement
    return UserModel.fromSupabase(user.toJson());
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Email ou mot de passe incorrect');
    }

    return UserModel.fromSupabase(response.user!.toJson());
  }

  @override
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  @override
  Future<void> updateProfile({
    required String userId,
    String? niveau,
    String? preference,
    String? objectif,
  }) async {
    final updates = <String, dynamic>{};
    if (niveau != null) updates['niveau'] = niveau;
    if (preference != null) updates['preference'] = preference;
    if (objectif != null) updates['objectif'] = objectif;

    if (updates.isEmpty) return;

    final response = await httpClient.patch(
      Uri.parse('$baseUrl/api/profile'),
      headers: _headers,
      body: jsonEncode(updates),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Échec de la mise à jour du profil (${response.statusCode})');
    }
  }

  @override
  Future<void> deleteAccount({required String userId}) async {
    final response = await httpClient.delete(
      Uri.parse('$baseUrl/api/account'),
      headers: _headers,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Échec de la suppression du compte (${response.statusCode})');
    }

    await supabase.auth.signOut();
  }

  @override
  UserModel? getCurrentUser() {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    return UserModel.fromSupabase(user.toJson());
  }
}
