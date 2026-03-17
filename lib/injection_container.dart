import 'package:get_it/get_it.dart';
import 'features/wine/data/datasources/wine_local_data_source.dart';
import 'features/wine/data/repositories/wine_repository_impl.dart';
import 'features/wine/domain/repositories/wine_repository.dart';
import 'features/wine/domain/usecases/get_all_wines.dart';
import 'features/wine/domain/usecases/get_last_wine.dart';
import 'features/wine/presentation/bloc/wine_bloc.dart';

// TODO : décommenter quand les classes auth seront créées
// import 'features/auth/data/datasources/auth_remote_data_source.dart';
// import 'features/auth/data/repositories/auth_repository_impl.dart';
// import 'features/auth/domain/repositories/auth_repository.dart';
// import 'features/auth/domain/usecases/register_user.dart';
// import 'features/auth/domain/usecases/login_user.dart';
// import 'features/auth/domain/usecases/sign_in_with_google.dart';
// import 'features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ─── Auth ──────────────────────────────────────────────────────────────────
  // TODO : décommenter quand les classes auth seront créées

  // Bloc
  // sl.registerFactory(
  //   () => AuthBloc(
  //     registerUser: sl(),
  //     loginUser: sl(),
  //     signInWithGoogle: sl(),
  //   ),
  // );

  // Use cases
  // sl.registerLazySingleton(() => RegisterUser(sl()));
  // sl.registerLazySingleton(() => LoginUser(sl()));
  // sl.registerLazySingleton(() => SignInWithGoogle(sl()));

  // Repository
  // sl.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(remoteDataSource: sl()),
  // );

  // Data sources
  // sl.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthRemoteDataSourceImpl(),
  // );

  // ─── Wine ──────────────────────────────────────────────────────────────────

  // Bloc
  sl.registerFactory(
    () => WineBloc(
      getLastWine: sl(),
      getAllWines: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetLastWine(sl()));
  sl.registerLazySingleton(() => GetAllWines(sl()));

  // Repository
  sl.registerLazySingleton<WineRepository>(
    () => WineRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<WineLocalDataSource>(
    () => WineLocalDataSourceImpl(),
  );
}