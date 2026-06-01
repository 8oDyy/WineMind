import 'package:equatable/equatable.dart';

import 'wine.dart';

/// Une catégorie de recommandations affichée comme une rangée horizontale dans
/// la page Découvertes (ex. « Pour vous », « Petits prix »). Les libellés
/// (`title`/`subtitle`) sont fournis prêts à l'affichage par le backend ;
/// l'UI ne fait aucune logique métier dessus.
class WineCategory extends Equatable {
  /// Identifiant stable de la catégorie (ex. `for_you`, `under_20`).
  final String key;

  /// Titre affiché de la rangée (français, prêt à l'emploi).
  final String title;

  /// Sous-titre optionnel (français), `null` si absent.
  final String? subtitle;

  /// Vins de la catégorie (rows catalogue `wines`).
  final List<Wine> wines;

  const WineCategory({
    required this.key,
    required this.title,
    this.subtitle,
    this.wines = const [],
  });

  @override
  List<Object?> get props => [key, title, subtitle, wines];
}
