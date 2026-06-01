import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Met à jour le profil de l'utilisateur connecté.
///
/// Seuls les champs non-null sont transmis (patch partiel) ; l'API renvoie le
/// row `profiles` complet, mappé en [UserEntity] à jour.
class UpdateProfile implements UseCase<UserEntity, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) {
    return repository.updateProfile(
      niveau: params.niveau,
      preference: params.preference,
      objectif: params.objectif,
      prenom: params.prenom,
      nom: params.nom,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String? niveau;
  final String? preference;
  final String? objectif;
  final String? prenom;
  final String? nom;

  const UpdateProfileParams({
    this.niveau,
    this.preference,
    this.objectif,
    this.prenom,
    this.nom,
  });

  @override
  List<Object?> get props => [niveau, preference, objectif, prenom, nom];
}
