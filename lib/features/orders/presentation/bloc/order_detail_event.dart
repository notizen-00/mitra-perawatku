part of 'order_detail_bloc.dart';

abstract class OrderDetailEvent extends Equatable {
  const OrderDetailEvent();

  @override
  List<Object?> get props => [];
}

class OrderDetailRequested extends OrderDetailEvent {
  const OrderDetailRequested(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class OrderDetailRefreshed extends OrderDetailEvent {
  const OrderDetailRefreshed(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}
