import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Auth
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/delete_account.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/logout_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Wine
import 'features/wine/data/datasources/wine_remote_data_source.dart';
import 'features/wine/data/repositories/wine_repository_impl.dart';
import 'features/wine/domain/repositories/wine_repository.dart';
import 'features/wine/domain/usecases/get_all_wines.dart';
import 'features/wine/domain/usecases/get_last_wine.dart';
import 'features/wine/domain/usecases/update_wine_stock.dart';
import 'features/wine/presentation/bloc/cellar_bloc.dart';
import 'features/wine/presentation/bloc/wine_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  if (sl.isRegistered<WineBloc>()) return;

  // ── Core ──
  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );

  // ── Auth ──
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUser: sl(),
      registerUser: sl(),
      logoutUser: sl(),
      getCurrentUser: sl(),
      deleteAccount: sl(),
    ),
  );
  // Use cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LogoutUser(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => DeleteAccount(sl()));
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  // Data source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // ── Wine ──
  // Blocs
  sl.registerFactory(
    () => WineBloc(
      getLastWine: sl(),
      getAllWines: sl(),
    ),
  );


  sl.registerFactory(
    () => CellarBloc(
      getAllWines: sl(),
    ),
  );
  // Use cases
  sl.registerLazySingleton(() => GetLastWine(sl()));
  sl.registerLazySingleton(() => GetAllWines(sl()));
  sl.registerLazySingleton(() => UpdateWineStock(sl()));
  // Repository
  sl.registerLazySingleton<WineRepository>(
    () => WineRepositoryImpl(remoteDataSource: sl()),
  );
  // Data source
  sl.registerLazySingleton<WineRemoteDataSource>(
    () => WineRemoteDataSourceImpl(sl()),
  );
}
