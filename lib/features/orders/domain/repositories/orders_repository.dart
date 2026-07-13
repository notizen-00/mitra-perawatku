import '../entities/order_booking.dart';
import '../entities/order_detail.dart';

abstract class OrdersRepository {
  Future<List<OrderBooking>> getOrders();

  Future<OrderDetail> getOrderDetail(int id);
}
