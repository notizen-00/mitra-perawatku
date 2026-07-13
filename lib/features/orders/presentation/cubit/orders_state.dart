part of 'orders_cubit.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();

  @override
  List<Object?> get props => [];
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();

  @override
  List<Object?> get props => [];
}

class OrdersLoaded extends OrdersState {
  const OrdersLoaded(this.orders);

  final List<OrderBooking> orders;

  @override
  List<Object?> get props => [orders];
}

class OrdersError extends OrdersState {
  const OrdersError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
