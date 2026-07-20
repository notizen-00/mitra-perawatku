import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/partner_location_sync_service.dart';
import '../../domain/entities/order_detail.dart';
import '../../domain/usecases/accept_service_booking.dart';
import '../../domain/usecases/add_service_booking_history.dart';
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
    this._addServiceBookingHistory,
    this._completeServiceBooking,
    this._locationSyncService,
  ) : super(const OrderDetailInitial()) {
    on<OrderDetailRequested>(_onRequested);
    on<OrderDetailRefreshed>(_onRefreshed);
    on<OrderDetailAccepted>(_onAccepted);
    on<OrderDetailRejected>(_onRejected);
    on<OrderDetailJourneyStarted>(_onJourneyStarted);
    on<OrderDetailArrived>(_onArrived);
    on<OrderDetailTreatmentStarted>(_onTreatmentStarted);
    on<OrderDetailCompleted>(_onCompleted);
  }

  final GetOrderDetail _getOrderDetail;
  final AcceptServiceBooking _acceptServiceBooking;
  final DeclineServiceBooking _declineServiceBooking;
  final StartJourney _startJourney;
  final AddServiceBookingHistory _addServiceBookingHistory;
  final CompleteServiceBooking _completeServiceBooking;
  final PartnerLocationSyncService _locationSyncService;

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
      action: () async {
        final detail = await _startJourney(event.id);
        if (detail.status.toLowerCase() == 'on_the_way') {
          _locationSyncService.startBookingLocationSync(detail.id);
        }
        return detail;
      },
    );
  }

  Future<void> _onCompleted(
    OrderDetailCompleted event,
    Emitter<OrderDetailState> emit,
  ) async {
    await _action(
      emit,
      action: () async {
        final detail = await _completeServiceBooking(event.id);
        _locationSyncService.stopBookingLocationSync(bookingId: event.id);
        return detail;
      },
    );
  }

  Future<void> _onArrived(
    OrderDetailArrived event,
    Emitter<OrderDetailState> emit,
  ) async {
    await _action(
      emit,
      action: () async {
        final detail = await _addServiceBookingHistory(
          id: event.id,
          title: 'Mitra sampai di lokasi',
          description: 'Mitra sudah tiba di alamat pasien.',
          treatmentType: 'arrival',
        );
        _locationSyncService.stopBookingLocationSync(bookingId: event.id);
        return detail;
      },
    );
  }

  Future<void> _onTreatmentStarted(
    OrderDetailTreatmentStarted event,
    Emitter<OrderDetailState> emit,
  ) async {
    await _action(
      emit,
      action: () => _addServiceBookingHistory(
        id: event.id,
        title: 'Penanganan pasien dimulai',
        description: 'Mitra mulai melakukan pemeriksaan dan penanganan pasien.',
        treatmentType: 'treatment_started',
      ),
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
