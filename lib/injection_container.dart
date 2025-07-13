import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'core/network/api_client.dart';
import 'core/network/network_info.dart';
import 'core/storage/secure_storage.dart';
import 'core/storage/shared_preferences_helper.dart';
// Data
import 'data/datasources/local/auth_local_datasource.dart';
// Add these profile imports
// import 'data/datasources/local/profile_local_datasource.dart';
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/datasources/remote/profile_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/profile_repository_impl.dart';
// Domain
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/logout_usecase.dart';
import 'domain/usecases/auth/refresh_token_usecase.dart';
import 'domain/usecases/auth/register_usecase.dart';
import 'domain/usecases/auth/verify_phone_usecase.dart';
import 'domain/usecases/profile/get_profile_usecase.dart';
import 'domain/usecases/profile/patch_profile_usecase.dart';
import 'domain/usecases/profile/update_profile_usecase.dart';
// Presentation
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/navigation/navigation_bloc.dart';
import 'presentation/bloc/profile/profile_bloc.dart'; // Add this

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => http.Client());

  // Core
  sl.registerLazySingleton<SecureStorage>(
    () => SecureStorage(sl()),
  );
  sl.registerLazySingleton<SharedPreferencesHelper>(
    () => SharedPreferencesHelper(sl()),
  );
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      client: sl(),
      secureStorage: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: sl(),
      sharedPreferencesHelper: sl(),
    ),
  );

  // Add profile data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiClient: sl()),
  );
  // sl.registerLazySingleton<ProfileLocalDataSource>(
  //   () => ProfileLocalDataSourceImpl(
  //     secureStorage: sl(),
  //     sharedPreferencesHelper: sl(),
  //   ),
  // );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Add profile repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      // localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => VerifyPhoneUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => RefreshTokenUseCase(sl()));

  // Add profile use cases
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => PatchProfileUseCase(sl()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      verifyPhoneUseCase: sl(),
      registerUseCase: sl(),
      logoutUseCase: sl(),
      refreshTokenUseCase: sl(),
      authRepository: sl(),
    ),
  );
  sl.registerFactory(() => NavigationBloc());

  // Add ProfileBloc
  sl.registerFactory(
    () => ProfileBloc(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      patchProfileUseCase: sl(),
    ),
  );
}
