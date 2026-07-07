import 'package:get_it/get_it.dart';

import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_summary.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl());
  sl.registerLazySingleton(() => GetHomeSummary(sl<HomeRepository>()));
}
