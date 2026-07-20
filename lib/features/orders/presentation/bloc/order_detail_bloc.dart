import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/order_detail.dart';
import '../../domain/usecases/accept_service_booking.dart';
import '../../domain/usecases/complete_service_booking.dart';
import '../../domain/usecases/decline_service_booking.dart';
import '../../domain/usecases/get_order_detail.dart';
import '../../domain/usecases/start_journey.dart';

part 'order_detail_event.dart';
part 'order_detail_state.dart';

class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  OrderDetailBloc(
    this._getOrderDetail,
    this._acceptServiceBooking,
    this._declineServiceBooking,
    this._startJourney,
    this._completeServiceBooking,
  ) : super(const OrderDetailInitial()) {
    on<OrderDetailRequested>(_onRequested);
    on<OrderDetailRefreshed>(_onRefreshed);
    on<OrderDetailAccepted>(_onAccepted);
    on<OrderDetailRejected>(_onRejected);
    on<OrderDetailJourneyStarted>(_onJourneyStarted);
    on<OrderDetailCompleted>(_onCompleted);
  }

  final GetOrderDetail _getOrderDetail;
  final AcceptServiceBooking _acceptServiceBooking;
  final DeclineServiceBooking _declineServiceBooking;
  final StartJourney _startJourney;
  final CompleteServiceBooking _completeServiceBooking;

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

  Future<void> _onAccepted(
    OrderDetailAccepted event,
    Emitter<OrderDetailState> emit,
  ) async {
    await _action(
      emit,
      action: () => _acceptServiceBooking(event.id),
    );
  }

  Future<void> _onRejected(
    OrderDetailRejected event,
    Emitter<OrderDetailState> emit,
  ) async {
    await _action(
      emit,
      action: () => _declineServiceBooking(event.id),
    );
  }

  Future<void> _onJourneyStarted(
    OrderDetailJourneyStarted event,
    Emitter<OrderDetailState> emit,
  ) async {
    await _action(
      emit,
      action: () => _startJourney(event.id),
    );
  }

  Future<void> _onCompleted(
    OrderDetailCompleted event,
    Emitter<OrderDetailState> emit,
  ) async {
    await _action(
      emit,
      action: () => _completeServiceBooking(event.id),
    );
  }

  Future<void> _action(
    Emitter<OrderDetailState> emit, {
    required Future<OrderDetail> Function() action,
  }) async {
    try {
      emit(OrderDetailLoaded(await action()));
    } on Failure catch (error) {
      emit(OrderDetailError(error.message));
    } catch (_) {
      emit(const OrderDetailError('Aksi pesanan belum bisa diproses.'));
    }
  }
}
