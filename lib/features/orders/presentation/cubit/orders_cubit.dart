import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/order_booking.dart';
import '../../domain/usecases/get_orders.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._getOrders) : super(const OrdersInitial());

  final GetOrders _getOrders;

  Future<void> load() async {
    emit(const OrdersLoading());

    try {
      emit(OrdersLoaded(await _getOrders()));
    } on Failure catch (error) {
      emit(OrdersError(error.message));
    } catch (_) {
      emit(const OrdersError('Order belum bisa dimuat.'));
    }
  }
}
