/// Configuration globale de l'application.
///
/// Ce fichier est l'UNIQUE source de vérité pour l'URL de base de l'API HTTP.
/// Toute modification de l'environnement cible (local, staging, prod) doit
/// se faire ici et ici seulement.
class AppConfig {
  AppConfig._();

  /// URL de base de l'API en production.
  static const String apiBaseUrl = 'https://winemind.fr';
}
