import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class DeleteAccount implements UseCase<void, DeleteAccountParams> {
  final AuthRepository repository;

  DeleteAccount(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteAccountParams params) {
    return repository.deleteAccount(userId: params.userId);
  }
}

class DeleteAccountParams extends Equatable {
  final String userId;

  const DeleteAccountParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}
