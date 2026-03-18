import 'package:get_it/get_it.dart';

// ─── Wine ──────────────────────────────────────────────────────────────────
import 'features/wine/data/datasources/wine_local_data_source.dart';
import 'features/wine/data/repositories/wine_repository_impl.dart';
import 'features/wine/domain/repositories/wine_repository.dart';
import 'features/wine/domain/usecases/get_all_wines.dart';
import 'features/wine/domain/usecases/get_last_wine.dart';
import 'features/wine/presentation/bloc/wine_bloc.dart';

// ─── Auth ──────────────────────────────────────────────────────────────────
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/register_user.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ─── Auth ────────────────────────────────────────────────────────────────

  // Use cases
  sl.registerLazySingleton(() => RegisterUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  // ─── Wine ────────────────────────────────────────────────────────────────

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