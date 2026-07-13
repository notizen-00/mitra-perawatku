import '../entities/order_detail.dart';
import '../repositories/orders_repository.dart';

class DeclineServiceBooking {
  const DeclineServiceBooking(this.repository);

  final OrdersRepository repository;

  Future<OrderDetail> call(int id) => repository.declineServiceBooking(id);
}
