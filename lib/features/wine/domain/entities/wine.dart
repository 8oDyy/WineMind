import 'package:equatable/equatable.dart';

class Wine extends Equatable {
  final String? id;
  final String? cellarId;
  final String name;
  final String year;
  final String type;
  final String region;
  final double rating;
  final int points;
  final String apogee;
  final int stock;
  final String? description;
  final String? designation;
  final double? price;
  final String? province;
  final String? country;
  final String? variety;
  final String? winery;
  final String? location;
  final List<String> foodPairings;

  /// Niveaux gustatifs normalisés dans [0, 1], ou `null` si non renseignés.
  /// `null` = « profil inconnu » (à distinguer d'un vrai 0) → le radar n'est
  /// alors pas affiché plutôt que de montrer un faux profil par défaut.
  final double? bodyLevel;
  final double? tanninLevel;
  final double? fruitLevel;

  /// Fenêtre de garde (années) : début / pic / fin de la période optimale.
  /// `null` si non renseignées → le graphique d'apogée n'est pas affiché.
  /// (`apogee`, String libre historique, reste pour rétro-compat textuelle.)
  final int? drinkFrom;
  final int? peakYear;
  final int? drinkTo;

  /// Timestamp (ISO) d'enrichissement IA du vin catalogue, `null` si jamais
  /// enrichi. Sert à déclencher l'enrichissement à l'ouverture de la fiche.
  final String? enrichedAt;
  final String? imageUrl;
  final String? notes;
  final String? purchaseDate;
  final double? purchasePrice;

  /// Vrai si le vin catalogue a déjà été enrichi par l'IA.
  bool get isEnriched => enrichedAt != null;

  /// Vin de catalogue (vs vin custom saisi par l'utilisateur).
  bool get isCatalogWine => id != null;

  /// Vrai si le profil/accords/apogée semblent absents (vin non enrichi).
  /// Détection de secours quand `enrichedAt` n'est pas disponible.
  bool get hasDefaultData =>
      bodyLevel == null &&
      tanninLevel == null &&
      fruitLevel == null &&
      foodPairings.isEmpty &&
      drinkFrom == null &&
      peakYear == null &&
      drinkTo == null;

  const Wine({
    this.id,
    this.cellarId,
    required this.name,
    required this.year,
    required this.type,
    required this.region,
    required this.rating,
    required this.points,
    required this.apogee,
    required this.stock,
    this.description,
    this.designation,
    this.price,
    this.province,
    this.country,
    this.variety,
    this.winery,
    this.location,
    this.foodPairings = const [],
    this.bodyLevel,
    this.tanninLevel,
    this.fruitLevel,
    this.drinkFrom,
    this.peakYear,
    this.drinkTo,
    this.enrichedAt,
    this.imageUrl,
    this.notes,
    this.purchaseDate,
    this.purchasePrice,
  });

  /// Copie en surchargeant les champs fournis. Les niveaux gustatifs et la
  /// fenêtre de garde acceptent un override explicite (y compris non-null)
  /// pour la fusion des données enrichies.
  Wine copyWith({
    String? id,
    String? cellarId,
    String? name,
    String? year,
    String? type,
    String? region,
    double? rating,
    int? points,
    String? apogee,
    int? stock,
    String? description,
    String? designation,
    double? price,
    String? province,
    String? country,
    String? variety,
    String? winery,
    String? location,
    List<String>? foodPairings,
    double? bodyLevel,
    double? tanninLevel,
    double? fruitLevel,
    int? drinkFrom,
    int? peakYear,
    int? drinkTo,
    String? enrichedAt,
    String? imageUrl,
    String? notes,
    String? purchaseDate,
    double? purchasePrice,
  }) {
    return Wine(
      id: id ?? this.id,
      cellarId: cellarId ?? this.cellarId,
      name: name ?? this.name,
      year: year ?? this.year,
      type: type ?? this.type,
      region: region ?? this.region,
      rating: rating ?? this.rating,
      points: points ?? this.points,
      apogee: apogee ?? this.apogee,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      designation: designation ?? this.designation,
      price: price ?? this.price,
      province: province ?? this.province,
      country: country ?? this.country,
      variety: variety ?? this.variety,
      winery: winery ?? this.winery,
      location: location ?? this.location,
      foodPairings: foodPairings ?? this.foodPairings,
      bodyLevel: bodyLevel ?? this.bodyLevel,
      tanninLevel: tanninLevel ?? this.tanninLevel,
      fruitLevel: fruitLevel ?? this.fruitLevel,
      drinkFrom: drinkFrom ?? this.drinkFrom,
      peakYear: peakYear ?? this.peakYear,
      drinkTo: drinkTo ?? this.drinkTo,
      enrichedAt: enrichedAt ?? this.enrichedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      notes: notes ?? this.notes,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cellarId,
        name,
        year,
        type,
        region,
        rating,
        points,
        apogee,
        stock,
        description,
        designation,
        price,
        province,
        country,
        variety,
        winery,
        location,
        foodPairings,
        bodyLevel,
        tanninLevel,
        fruitLevel,
        drinkFrom,
        peakYear,
        drinkTo,
        enrichedAt,
        imageUrl,
        notes,
        purchaseDate,
        purchasePrice,
      ];
}
