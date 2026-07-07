import '../../../../core/errors/failures.dart';
import '../../domain/entities/home_summary.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<HomeSummary> getHomeSummary() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    try {
      return const HomeSummary(
        title: 'Perawatku Mitra',
        subtitle: 'Siap menerima layanan kesehatan',
        activeOrders: 3,
        todayIncome: 845000,
        todayOrders: 8,
        rating: 4.9,
        upcomingSchedule: 'Homecare demam - 14.30',
        recentActivity: 'Pembayaran layanan SVB-1024 berhasil diterima',
        isAvailable: true,
      );
    } on Exception {
      throw const ServerFailure();
    }
  }
}
