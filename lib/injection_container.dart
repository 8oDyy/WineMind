import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';

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

// Wine Label
import 'features/wine_label/data/datasources/wine_label_remote_data_source.dart';
import 'features/wine_label/data/datasources/wine_label_analysis_remote_data_source.dart';
import 'features/wine_label/data/datasources/wine_label_add_remote_data_source.dart';
import 'features/wine_label/data/repositories/wine_label_repository_impl.dart';
import 'features/wine_label/data/repositories/wine_label_analysis_repository_impl.dart';
import 'features/wine_label/data/repositories/wine_label_add_repository_impl.dart';
import 'features/wine_label/domain/repositories/wine_label_repository.dart';
import 'features/wine_label/domain/repositories/wine_label_analysis_repository.dart';
import 'features/wine_label/domain/repositories/wine_label_add_repository.dart';
import 'features/wine_label/domain/usecases/upload_wine_label.dart';
import 'features/wine_label/domain/usecases/analyze_wine_label.dart';
import 'features/wine_label/domain/usecases/add_wine_to_cellar.dart';
import 'features/wine_label/presentation/bloc/wine_label_bloc.dart';

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
    () => AuthRemoteDataSourceImpl(
      supabase: sl<SupabaseClient>(),
      httpClient: sl<http.Client>(),
      baseUrl: AppConfig.apiBaseUrl,
    ),
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
      baseUrl: AppConfig.apiBaseUrl,
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
    () => WineRemoteDataSourceImpl(
      client: sl<http.Client>(),
      baseUrl: AppConfig.apiBaseUrl,
      supabase: sl<SupabaseClient>(),
    ),
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
      baseUrl: AppConfig.apiBaseUrl,
    ),
  );

  // Wine Label Feature
  // Data sources
  sl.registerLazySingleton<WineLabelRemoteDataSource>(
    () => WineLabelRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<WineLabelAnalysisRemoteDataSource>(
    () => WineLabelAnalysisRemoteDataSourceImpl(
      client: sl(),
      baseUrl: AppConfig.apiBaseUrl,
    ),
  );

  sl.registerLazySingleton<WineLabelAddRemoteDataSource>(
    () => WineLabelAddRemoteDataSourceImpl(
      client: sl(),
      baseUrl: AppConfig.apiBaseUrl,
    ),
  );

  // Repositories
  sl.registerLazySingleton<WineLabelRepository>(
    () => WineLabelRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<WineLabelAnalysisRepository>(
    () => WineLabelAnalysisRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<WineLabelAddRepository>(
    () => WineLabelAddRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton<UploadWineLabel>(
    () => UploadWineLabel(sl()),
  );

  sl.registerLazySingleton<AnalyzeWineLabel>(
    () => AnalyzeWineLabel(sl()),
  );

  sl.registerLazySingleton<AddWineToCellar>(
    () => AddWineToCellar(sl()),
  );

  // BLoC
  sl.registerFactory<WineLabelBloc>(
    () => WineLabelBloc(
      uploadWineLabel: sl(),
      analyzeWineLabel: sl(),
      addWineToCellar: sl(),
    ),
  );
}
