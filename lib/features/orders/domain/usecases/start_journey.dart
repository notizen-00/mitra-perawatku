import '../entities/order_detail.dart';
import '../repositories/orders_repository.dart';

class StartJourney {
  const StartJourney(this.repository);

  final OrdersRepository repository;

  Future<OrderDetail> call(int id) => repository.startJourney(id);
}
