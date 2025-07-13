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
import 'data/datasources/local/alarm_local_datasource.dart';
// Data
import 'data/datasources/local/auth_local_datasource.dart';
import 'data/datasources/remote/alarm_remote_datasource.dart';
import 'data/datasources/remote/auth_remote_datasource.dart';
import 'data/datasources/remote/notification_remote_datasource.dart';
import 'data/datasources/remote/profile_remote_datasource.dart';
import 'data/repositories/alarm_repository_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/notification_repository_impl.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'domain/repositories/alarm_repository.dart';
// Domain
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/notification_repository.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/usecases/alarm/create_alarm_usecase.dart';
import 'domain/usecases/alarm/delete_alarm_usecase.dart';
import 'domain/usecases/alarm/get_alarms_usecase.dart';
import 'domain/usecases/alarm/toggle_alarm_usecase.dart';
import 'domain/usecases/alarm/update_alarm_usecase.dart';
import 'domain/usecases/auth/login_usecase.dart';
import 'domain/usecases/auth/logout_usecase.dart';
import 'domain/usecases/auth/refresh_token_usecase.dart';
import 'domain/usecases/auth/register_usecase.dart';
import 'domain/usecases/auth/verify_phone_usecase.dart';
import 'domain/usecases/notification/get_notifications_usecase.dart';
import 'domain/usecases/notification/mark_all_as_read_usecase.dart';
import 'domain/usecases/notification/mark_as_read_usecase.dart';
import 'domain/usecases/profile/get_profile_usecase.dart';
import 'domain/usecases/profile/patch_profile_usecase.dart';
import 'domain/usecases/profile/update_profile_usecase.dart';
//Presentation
import 'presentation/bloc/alarm/alarm_bloc.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/navigation/navigation_bloc.dart';
import 'presentation/bloc/notification/notification_bloc.dart';
import 'presentation/bloc/profile/profile_bloc.dart';

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

  sl.registerLazySingleton<AlarmLocalDataSource>(
    () => AlarmLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );

  sl.registerLazySingleton<AlarmRemoteDataSource>(
    () => AlarmRemoteDataSourceImpl(apiClient: sl()),
  );

  // Profile data sources
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiClient: sl()),
  );

  // Notification data sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(apiClient: sl()),
  );

  // Alarm data sources
  sl.registerLazySingleton<AlarmRepository>(
    () => AlarmRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => VerifyPhoneUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => RefreshTokenUseCase(sl()));

  // Profile use cases
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => PatchProfileUseCase(sl()));

  // Notification use cases
  sl.registerLazySingleton(() => GetNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => MarkAsReadUseCase(sl()));
  sl.registerLazySingleton(() => MarkAllAsReadUseCase(sl()));

  // Alarm use cases
  sl.registerLazySingleton(() => CreateAlarmUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAlarmUseCase(sl()));
  sl.registerLazySingleton(() => GetAlarmsUseCase(sl()));
  sl.registerLazySingleton(() => ToggleAlarmUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAlarmUseCase(sl()));

  // BLoCs
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

  sl.registerFactory(
    () => ProfileBloc(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      patchProfileUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => NotificationBloc(
      getNotificationsUseCase: sl(),
      markAsReadUseCase: sl(),
      markAllAsReadUseCase: sl(),
    ),
  );

  sl.registerFactory(() => AlarmBloc(
        createAlarmUseCase: sl(),
        deleteAlarmUseCase: sl(),
        getAlarmsUseCase: sl(),
        toggleAlarmUseCase: sl(),
        updateAlarmUseCase: sl(),
      ));
}
