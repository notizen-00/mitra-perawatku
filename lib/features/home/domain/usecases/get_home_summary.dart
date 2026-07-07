import '../entities/home_summary.dart';
import '../repositories/home_repository.dart';

class GetHomeSummary {
  const GetHomeSummary(this.repository);

  final HomeRepository repository;

  Future<HomeSummary> call() async => repository.getHomeSummary();
}
