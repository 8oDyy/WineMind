import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
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

// AI
import 'features/ai/data/datasources/ai_remote_data_source.dart';
import 'features/ai/data/repositories/ai_repository_impl.dart';
import 'features/ai/domain/repositories/ai_repository.dart';
import 'features/ai/domain/usecases/send_chat_message.dart';
import 'features/ai/presentation/bloc/chat_bloc.dart';

// Wine
import 'features/wine/data/datasources/wine_remote_data_source.dart';
import 'features/wine/data/repositories/wine_repository_impl.dart';
import 'features/wine/domain/repositories/wine_repository.dart';
import 'features/wine/domain/usecases/get_all_wines.dart';
import 'features/wine/domain/usecases/get_last_wine.dart';
import 'features/wine/domain/usecases/update_wine_stock.dart';
import 'features/wine/presentation/bloc/cellar_bloc.dart';
import 'features/wine/presentation/bloc/wine_bloc.dart';

// DishPicture
import 'features/dishpicture/data/datasources/dish_picture_remote_data_source.dart';
import 'features/dishpicture/data/repositories/dish_picture_repository_impl.dart';
import 'features/dishpicture/domain/repositories/dish_picture_repository.dart';
import 'features/dishpicture/domain/usecases/upload_picture.dart';
import 'features/dishpicture/presentation/bloc/dish_picture_bloc.dart';

// DishAnalysis
import 'features/dishpicture/data/datasources/dish_analysis_remote_data_source.dart';
import 'features/dishpicture/data/repositories/dish_analysis_repository_impl.dart';
import 'features/dishpicture/domain/repositories/dish_analysis_repository.dart';
import 'features/dishpicture/domain/usecases/analyze_dish.dart';
import 'features/dishpicture/presentation/bloc/dish_analysis_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  if (sl.isRegistered<DishAnalysisBloc>()) return;

  // ── Core ──
  sl.registerLazySingleton<SupabaseClient>(
    () => Supabase.instance.client,
  );
  sl.registerLazySingleton<http.Client>(() => http.Client());

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

  // ── AI ──
  // Bloc
  sl.registerFactory(
    () => ChatBloc(sendChatMessage: sl()),
  );
  // Use cases
  sl.registerLazySingleton(() => SendChatMessage(sl()));
  // Repository
  sl.registerLazySingleton<AiRepository>(
    () => AiRepositoryImpl(remoteDataSource: sl()),
  );
  // Data source
  sl.registerLazySingleton<AiRemoteDataSource>(
    () => AiRemoteDataSourceImpl(
      client: sl<http.Client>(),
      baseUrl: 'http://4.233.146.238:8000',
    ),
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

  // ── DishPicture ──
  // Bloc
  sl.registerFactory(
    () => DishPictureBloc(uploadPicture: sl()),
  );
  // Use case
  sl.registerLazySingleton(() => UploadPicture(sl()));
  // Repository
  sl.registerLazySingleton<DishPictureRepository>(
    () => DishPictureRepositoryImpl(remoteDataSource: sl()),
  );
  // Data source
  sl.registerLazySingleton<DishPictureRemoteDataSource>(
    () => DishPictureRemoteDataSourceImpl(sl()),
  );

  // ── DishAnalysis ──
  // Bloc
  sl.registerFactory(
    () => DishAnalysisBloc(analyzeDish: sl()),
  );
  // Use case
  sl.registerLazySingleton(() => AnalyzeDish(sl()));
  // Repository
  sl.registerLazySingleton<DishAnalysisRepository>(
    () => DishAnalysisRepositoryImpl(remoteDataSource: sl()),
  );
  // Data source
  sl.registerLazySingleton<DishAnalysisRemoteDataSource>(
    () => DishAnalysisRemoteDataSourceImpl(
      client: sl(),
      baseUrl: 'http://4.233.146.238:8000',
    ),
  );
}
