/// Configuration globale de l'application.
///
/// Ce fichier est l'UNIQUE source de vérité pour l'URL de base de l'API HTTP.
/// Toute modification de l'environnement cible (local, staging, prod) doit
/// se faire ici et ici seulement.
class AppConfig {
  AppConfig._();

  /// URL de base de l'API en production.
  static const String apiBaseUrl = 'https://winemind.fr';

  // ──────────────────────────────────────────────────────────────────────
  // Google Sign-In (flow natif iOS).
  //
  // Ces deux identifiants proviennent de Google Cloud Console (OAuth client IDs).
  // À renseigner UNE FOIS la console Google configurée :
  //   - googleIosClientId : client OAuth de type « iOS » (lié au bundle ID).
  //   - googleWebClientId : client OAuth de type « Web » (= serverClientId,
  //     c'est lui que Supabase et `signInWithIdToken` attendent comme audience).
  //
  // Tant qu'ils valent les placeholders ci-dessous, le bouton « Continuer avec
  // Google » lèvera une erreur explicite (cf. AuthRemoteDataSourceImpl).
  // ──────────────────────────────────────────────────────────────────────
  static const String googleIosClientId =
      '619170248964-2c6kuq0bdf5s0mfa9pnag34l5epb155g.apps.googleusercontent.com';
  static const String googleWebClientId =
      '619170248964-af1ihhmi5b4ojartsjc6eder38k79prv.apps.googleusercontent.com';

  /// Vrai tant que les client IDs Google n'ont pas été renseignés.
  static bool get isGoogleSignInConfigured =>
      !googleIosClientId.startsWith('TODO_') &&
      !googleWebClientId.startsWith('TODO_');
}
