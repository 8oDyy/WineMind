import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.prenom,
    required super.nom,
    super.niveau,
    super.preference,
    super.objectif,
  });

  // Depuis les métadonnées Supabase auth
  factory UserModel.fromSupabase(Map<String, dynamic> data) {
    final meta = data['user_metadata'] as Map<String, dynamic>? ?? {};
    return UserModel(
      id: data['id'] as String,
      email: data['email'] as String,
      prenom: meta['prenom'] as String? ?? '',
      nom: meta['nom'] as String? ?? '',
      niveau: meta['niveau'] as String?,
      preference: meta['preference'] as String?,
      objectif: meta['objectif'] as String?,
    );
  }

  // Depuis la table profiles Supabase
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      prenom: json['prenom'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      niveau: json['niveau'] as String?,
      preference: json['preference'] as String?,
      objectif: json['objectif'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'prenom': prenom,
        'nom': nom,
        'niveau': niveau,
        'preference': preference,
        'objectif': objectif,
      };
}