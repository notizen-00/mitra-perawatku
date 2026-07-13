import '../entities/order_detail.dart';
import '../repositories/orders_repository.dart';

class GetOrderDetail {
  const GetOrderDetail(this.repository);

  final OrdersRepository repository;

  Future<OrderDetail> call(int id) => repository.getOrderDetail(id);
}
