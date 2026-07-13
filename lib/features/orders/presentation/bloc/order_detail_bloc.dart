import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/order_detail.dart';
import '../../domain/usecases/get_order_detail.dart';

part 'order_detail_event.dart';
part 'order_detail_state.dart';

class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  OrderDetailBloc(this._getOrderDetail) : super(const OrderDetailInitial()) {
    on<OrderDetailRequested>(_onRequested);
    on<OrderDetailRefreshed>(_onRefreshed);
  }

  final GetOrderDetail _getOrderDetail;

  Future<void> _onRequested(
    OrderDetailRequested event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(const OrderDetailLoading());
    await _load(event.id, emit);
  }

  Future<void> _onRefreshed(
    OrderDetailRefreshed event,
    Emitter<OrderDetailState> emit,
  ) async {
    await _load(event.id, emit);
  }

  Future<void> _load(int id, Emitter<OrderDetailState> emit) async {
    try {
      emit(OrderDetailLoaded(await _getOrderDetail(id)));
    } on Failure catch (error) {
      emit(OrderDetailError(error.message));
    } catch (_) {
      emit(const OrderDetailError('Detail pesanan belum bisa dimuat.'));
    }
  }
}
