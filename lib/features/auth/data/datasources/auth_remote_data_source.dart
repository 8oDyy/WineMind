import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/app_config.dart';
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

  /// Connexion via Google (flow natif iOS → `signInWithIdToken` Supabase).
  Future<UserModel> signInWithGoogle();

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
  Future<UserModel> signInWithGoogle() async {
    // Garde-fou : tant que les client IDs Google ne sont pas renseignés dans
    // AppConfig, on échoue avec un message clair plutôt qu'une erreur native
    // opaque côté Google Sign-In.
    if (!AppConfig.isGoogleSignInConfigured) {
      throw Exception(
        'Connexion Google non configurée (client IDs manquants dans AppConfig).',
      );
    }

    // ── Choix nonce (contrat aligné avec Supabase) ──
    // On NE gère PAS de nonce côté Flutter. Le package `google_sign_in` v7 sur
    // iOS ne permet pas de garantir qu'un nonce custom injecté corresponde au
    // hash présent dans l'`idToken` renvoyé. Côté Supabase, le provider Google
    // doit donc être configuré avec **« Skip nonce checks » = ON**, sinon le
    // token serait rejeté. Les deux côtés sont ainsi cohérents : pas de nonce
    // ici, vérif nonce désactivée là-bas. (Conforme à l'exemple officiel
    // Supabase pour le flow natif Flutter.)
    final googleSignIn = GoogleSignIn.instance;

    // Initialisation du SDK Google : clientId iOS + serverClientId (Web)
    // attendu par Supabase comme audience du token d'identité.
    await googleSignIn.initialize(
      clientId: AppConfig.googleIosClientId,
      serverClientId: AppConfig.googleWebClientId,
    );

    // Déclenche le sélecteur de compte natif (peut lever GoogleSignInException
    // si l'utilisateur annule).
    final googleUser = await googleSignIn.authenticate(
      scopeHint: const ['email', 'profile'],
    );

    final idToken = googleUser.authentication.idToken;
    if (idToken == null) {
      throw Exception('Token Google manquant.');
    }

    // Récupère un access token Google avec les scopes voulus (nécessaire à
    // Supabase pour échanger l'identité contre une session).
    const scopes = ['email', 'profile'];
    final authorization =
        await googleUser.authorizationClient.authorizationForScopes(scopes) ??
            await googleUser.authorizationClient.authorizeScopes(scopes);

    final response = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: authorization.accessToken,
    );

    if (response.user == null) {
      throw Exception('Connexion Google échouée.');
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
