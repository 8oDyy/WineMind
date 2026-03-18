import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String prenom;
  final String nom;
  final String? niveau;
  final String? preference;
  final String? objectif;

  const UserEntity({
    required this.id,
    required this.email,
    required this.prenom,
    required this.nom,
    this.niveau,
    this.preference,
    this.objectif,
  });

  @override
  List<Object?> get props =>
      [id, email, prenom, nom, niveau, preference, objectif];
}