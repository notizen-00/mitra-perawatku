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
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/domain/usecases/delete_notification.dart';
import '../../features/notifications/domain/usecases/get_notifications.dart';
import '../../features/notifications/domain/usecases/mark_all_notifications_read.dart';
import '../../features/notifications/domain/usecases/mark_notification_read.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/domain/usecases/get_order_detail.dart';
import '../../features/orders/domain/usecases/get_orders.dart';
import '../../features/orders/presentation/bloc/order_detail_bloc.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/services/data/repositories/partner_services_repository_impl.dart';
import '../../features/services/domain/repositories/partner_services_repository.dart';
import '../../features/services/domain/usecases/get_partner_services.dart';
import '../../features/services/presentation/cubit/partner_services_cubit.dart';
import '../../features/tracking/data/repositories/tracking_repository_impl.dart';
import '../../features/tracking/domain/repositories/tracking_repository.dart';
import '../../features/tracking/domain/usecases/get_active_tracking.dart';
import '../../features/tracking/presentation/cubit/tracking_cubit.dart';
import '../../features/wallet/data/repositories/wallet_repository_impl.dart';
import '../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../features/wallet/domain/usecases/get_wallet_summary.dart';
import '../../features/wallet/presentation/cubit/wallet_cubit.dart';
import '../network/api_client.dart';
import '../services/auth_session.dart';
import '../services/partner_location_sync_service.dart';
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
  sl.registerLazySingleton(() => PartnerLocationSyncService(sl<ApiClient>()));
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
  sl.registerFactory(
    () => HomeCubit(
      sl<GetHomeSummary>(),
      sl<ReverbWebSocketService>(),
    ),
  );

  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(sl<ApiClient>(), sl<AuthSession>()),
  );
  sl.registerLazySingleton(() => GetOrders(sl<OrdersRepository>()));
  sl.registerLazySingleton(() => GetOrderDetail(sl<OrdersRepository>()));
  sl.registerFactory(() => OrdersCubit(sl<GetOrders>()));
  sl.registerFactory(() => OrderDetailBloc(sl<GetOrderDetail>()));

  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(sl<ApiClient>(), sl<AuthSession>()),
  );
  sl.registerLazySingleton(() => GetWalletSummary(sl<WalletRepository>()));
  sl.registerFactory(() => WalletCubit(sl<GetWalletSummary>()));

  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(sl<ApiClient>(), sl<AuthSession>()),
  );
  sl.registerLazySingleton(
    () => GetNotifications(sl<NotificationsRepository>()),
  );
  sl.registerLazySingleton(
    () => MarkNotificationRead(sl<NotificationsRepository>()),
  );
  sl.registerLazySingleton(
    () => MarkAllNotificationsRead(sl<NotificationsRepository>()),
  );
  sl.registerLazySingleton(
    () => DeleteNotification(sl<NotificationsRepository>()),
  );
  sl.registerFactory(
    () => NotificationsCubit(
      getNotifications: sl<GetNotifications>(),
      markAsRead: sl<MarkNotificationRead>(),
      markAllAsRead: sl<MarkAllNotificationsRead>(),
      deleteNotification: sl<DeleteNotification>(),
    ),
  );

  sl.registerLazySingleton<PartnerServicesRepository>(
    () => PartnerServicesRepositoryImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton(
    () => GetPartnerServices(sl<PartnerServicesRepository>()),
  );
  sl.registerFactory(() => PartnerServicesCubit(sl<GetPartnerServices>()));

  sl.registerLazySingleton<TrackingRepository>(
    () => TrackingRepositoryImpl(sl<ApiClient>(), sl<AuthSession>()),
  );
  sl.registerLazySingleton(() => GetActiveTracking(sl<TrackingRepository>()));
  sl.registerFactory(() => TrackingCubit(sl<GetActiveTracking>()));

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ApiClient>()),
  );
  sl.registerLazySingleton(() => GetProfile(sl<ProfileRepository>()));
  sl.registerFactory(() => ProfileCubit(sl<GetProfile>()));
}
