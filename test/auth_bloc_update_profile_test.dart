import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:winemind/core/error/failures.dart';
import 'package:winemind/features/auth/domain/entities/user_entity.dart';
import 'package:winemind/features/auth/domain/usecases/delete_account.dart';
import 'package:winemind/features/auth/domain/usecases/get_current_user.dart';
import 'package:winemind/features/auth/domain/usecases/login_user.dart';
import 'package:winemind/features/auth/domain/usecases/logout_user.dart';
import 'package:winemind/features/auth/domain/usecases/register_user.dart';
import 'package:winemind/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:winemind/features/auth/domain/usecases/update_profile.dart';
import 'package:winemind/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:winemind/features/auth/presentation/bloc/auth_event.dart';
import 'package:winemind/features/auth/presentation/bloc/auth_state.dart';

import 'auth_bloc_update_profile_test.mocks.dart';

@GenerateMocks([
  LoginUser,
  RegisterUser,
  LogoutUser,
  GetCurrentUser,
  DeleteAccount,
  SignInWithGoogle,
  UpdateProfile,
])
void main() {
  late MockLoginUser loginUser;
  late MockRegisterUser registerUser;
  late MockLogoutUser logoutUser;
  late MockGetCurrentUser getCurrentUser;
  late MockDeleteAccount deleteAccount;
  late MockSignInWithGoogle signInWithGoogle;
  late MockUpdateProfile updateProfile;

  // Utilisateur authentifié AVANT l'écriture (profil encore vide, comme à
  // l'onboarding juste après l'inscription).
  const tInitialUser = UserEntity(
    id: 'u1',
    email: 'a@b.fr',
    prenom: 'Hugo',
    nom: 'Boulicaut',
  );

  // Utilisateur renvoyé par le PATCH avec les 3 champs persistés.
  const tUpdatedUser = UserEntity(
    id: 'u1',
    email: 'a@b.fr',
    prenom: 'Hugo',
    nom: 'Boulicaut',
    niveau: 'Amateur',
    preference: 'Vin Rouge, Vin Blanc',
    objectif: 'Découvrir',
  );

  AuthBloc buildBloc() => AuthBloc(
        loginUser: loginUser,
        registerUser: registerUser,
        logoutUser: logoutUser,
        getCurrentUser: getCurrentUser,
        deleteAccount: deleteAccount,
        signInWithGoogle: signInWithGoogle,
        updateProfile: updateProfile,
      );

  setUp(() {
    loginUser = MockLoginUser();
    registerUser = MockRegisterUser();
    logoutUser = MockLogoutUser();
    getCurrentUser = MockGetCurrentUser();
    deleteAccount = MockDeleteAccount();
    signInWithGoogle = MockSignInWithGoogle();
    updateProfile = MockUpdateProfile();
  });

  group('AuthBloc — UpdateProfileEvent (persistance onboarding)', () {
    blocTest<AuthBloc, AuthState>(
      'authentifié + succès : émet InProgress puis Success avec le user à jour',
      build: () {
        when(updateProfile(any))
            .thenAnswer((_) async => const Right(tUpdatedUser));
        return buildBloc();
      },
      seed: () => const AuthAuthenticated(user: tInitialUser),
      act: (bloc) => bloc.add(const UpdateProfileEvent(
        niveau: 'Amateur',
        preference: 'Vin Rouge, Vin Blanc',
        objectif: 'Découvrir',
      )),
      expect: () => const [
        AuthProfileUpdateInProgress(user: tInitialUser),
        AuthProfileUpdateSuccess(user: tUpdatedUser),
      ],
      verify: (_) {
        final captured =
            verify(updateProfile(captureAny)).captured.single as UpdateProfileParams;
        expect(captured.niveau, 'Amateur');
        expect(captured.preference, 'Vin Rouge, Vin Blanc');
        expect(captured.objectif, 'Découvrir');
      },
    );

    blocTest<AuthBloc, AuthState>(
      'authentifié + échec : émet InProgress puis Failure en conservant le user',
      build: () {
        when(updateProfile(any))
            .thenAnswer((_) async => const Left(AuthFailure('boom')));
        return buildBloc();
      },
      seed: () => const AuthAuthenticated(user: tInitialUser),
      act: (bloc) => bloc.add(const UpdateProfileEvent(
        niveau: 'Amateur',
        preference: 'Vin Rouge, Vin Blanc',
        objectif: 'Découvrir',
      )),
      expect: () => const [
        AuthProfileUpdateInProgress(user: tInitialUser),
        AuthProfileUpdateFailure(user: tInitialUser, message: 'boom'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'non authentifié : ignore l\'événement, aucune écriture',
      build: () => buildBloc(),
      seed: () => const AuthUnauthenticated(),
      act: (bloc) => bloc.add(const UpdateProfileEvent(niveau: 'Amateur')),
      expect: () => const <AuthState>[],
      verify: (_) {
        verifyNever(updateProfile(any));
      },
    );
  });
}
