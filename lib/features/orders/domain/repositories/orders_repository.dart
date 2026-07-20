import '../entities/order_booking.dart';
import '../entities/order_detail.dart';

abstract class OrdersRepository {
  Future<List<OrderBooking>> getOrders();

  Future<OrderDetail> getOrderDetail(int id);

  Future<OrderDetail> acceptServiceBooking(int id);

  Future<OrderDetail> declineServiceBooking(int id);

  Future<OrderDetail> startJourney(int id);

  Future<OrderDetail> addServiceBookingHistory({
    required int id,
    required String title,
    required String description,
    required String treatmentType,
  });

  Future<OrderDetail> completeServiceBooking(int id);
}
