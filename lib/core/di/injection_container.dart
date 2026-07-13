import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_mitra.dart';
import '../../features/auth/domain/usecases/register_mitra.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_summary.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../network/api_client.dart';
import '../services/auth_session.dart';
import '../services/reverb_websocket_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  if (sl.isRegistered<AuthSession>()) return;

  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
  sl.registerLazySingleton(() => AuthSession(sl<FlutterSecureStorage>()));
  await sl<AuthSession>().restore();
  sl.registerLazySingleton(() => ApiClient(sl<AuthSession>()));
  sl.registerLazySingleton(
    () => ReverbWebSocketService(sl<ApiClient>(), sl<AuthSession>()),
  );

  sl.registerLazySingleton(() => AuthRemoteDataSource(sl<ApiClient>()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>(), sl<AuthSession>()),
  );
  sl.registerLazySingleton(() => LoginMitra(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterMitra(sl<AuthRepository>()));
  sl.registerFactory(
    () => AuthCubit(
      loginMitra: sl<LoginMitra>(),
      registerMitra: sl<RegisterMitra>(),
    ),
  );

  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(sl<ApiClient>(), sl<AuthSession>()),
  );
  sl.registerLazySingleton(() => GetHomeSummary(sl<HomeRepository>()));
  sl.registerFactory(() => HomeCubit(sl<GetHomeSummary>()));
}
