part of 'order_detail_bloc.dart';

abstract class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object?> get props => [];
}

class OrderDetailInitial extends OrderDetailState {
  const OrderDetailInitial();
}

class OrderDetailLoading extends OrderDetailState {
  const OrderDetailLoading();
}

class OrderDetailLoaded extends OrderDetailState {
  const OrderDetailLoaded(this.order);

  final OrderDetail order;

  @override
  List<Object?> get props => [order];
}

class OrderDetailError extends OrderDetailState {
  const OrderDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
