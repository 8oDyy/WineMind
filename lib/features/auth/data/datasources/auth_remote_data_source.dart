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
 
  UserModel? getCurrentUser();
}
 
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;
 
  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String prenom,
    required String nom,
  }) async {
    // 1. SignUp — le trigger Supabase insère automatiquement dans profiles
    final response = await _client.auth.signUp(
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
    final loginResponse = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
 
    if (loginResponse.user == null) {
      throw Exception(
        'Login échoué — vérifie que "Confirm email" est désactivé dans Supabase Auth settings',
      );
    }
 
    final user = _client.auth.currentUser;
 
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
    final response = await _client.auth.signInWithPassword(
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
    await _client.auth.signOut();
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
 
    await _client.from('profiles').update(updates).eq('id', userId);
  }
 
  @override
  UserModel? getCurrentUser() {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return UserModel.fromSupabase(user.toJson());
  }
}