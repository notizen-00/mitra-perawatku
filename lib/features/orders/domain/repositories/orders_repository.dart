import '../entities/order_booking.dart';

abstract class OrdersRepository {
  Future<List<OrderBooking>> getOrders();
}
