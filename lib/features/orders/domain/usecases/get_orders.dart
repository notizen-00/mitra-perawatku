import '../entities/order_booking.dart';
import '../repositories/orders_repository.dart';

class GetOrders {
  const GetOrders(this.repository);

  final OrdersRepository repository;

  Future<List<OrderBooking>> call() => repository.getOrders();
}
