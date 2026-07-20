import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/partner_location_sync_service.dart';
import '../../domain/entities/order_booking.dart';
import '../../domain/usecases/accept_service_booking.dart';
import '../../domain/usecases/decline_service_booking.dart';
import '../../domain/usecases/get_orders.dart';
import '../../domain/usecases/start_journey.dart';

part 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(
    this._getOrders,
    this._acceptServiceBooking,
    this._declineServiceBooking,
    this._startJourney,
    this._locationSyncService,
  ) : super(const OrdersInitial());

  final GetOrders _getOrders;
  final AcceptServiceBooking _acceptServiceBooking;
  final DeclineServiceBooking _declineServiceBooking;
  final StartJourney _startJourney;
  final PartnerLocationSyncService _locationSyncService;

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

  Future<void> accept(int id) async {
    await _action(() => _acceptServiceBooking(id));
  }

  Future<void> decline(int id) async {
    await _action(() => _declineServiceBooking(id));
  }

  Future<void> startJourney(int id) async {
    await _action(() async {
      final detail = await _startJourney(id);
      if (detail.status.toLowerCase() == 'on_the_way') {
        _locationSyncService.startBookingLocationSync(detail.id);
      }
      return detail;
    });
  }

  Future<void> _action(Future<Object?> Function() action) async {
    final current = state;

    try {
      await action();
      await load();
    } on Failure catch (error) {
      emit(OrdersError(error.message));
      if (current is OrdersLoaded) emit(current);
    } catch (_) {
      emit(const OrdersError('Aksi order belum bisa diproses.'));
      if (current is OrdersLoaded) emit(current);
    }
  }
}
