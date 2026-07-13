import '../entities/order_detail.dart';
import '../repositories/orders_repository.dart';

class AcceptServiceBooking {
  const AcceptServiceBooking(this.repository);

  final OrdersRepository repository;

  Future<OrderDetail> call(int id) => repository.acceptServiceBooking(id);
}
