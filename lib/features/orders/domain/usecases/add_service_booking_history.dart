import '../entities/order_detail.dart';
import '../repositories/orders_repository.dart';

class AddServiceBookingHistory {
  const AddServiceBookingHistory(this.repository);

  final OrdersRepository repository;

  Future<OrderDetail> call({
    required int id,
    required String title,
    required String description,
    required String treatmentType,
  }) {
    return repository.addServiceBookingHistory(
      id: id,
      title: title,
      description: description,
      treatmentType: treatmentType,
    );
  }
}
