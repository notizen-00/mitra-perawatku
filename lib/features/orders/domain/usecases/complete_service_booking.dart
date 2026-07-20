import '../entities/order_detail.dart';
import '../repositories/orders_repository.dart';

class CompleteServiceBooking {
  const CompleteServiceBooking(this.repository);

  final OrdersRepository repository;

  Future<OrderDetail> call(int id) => repository.completeServiceBooking(id);
}
