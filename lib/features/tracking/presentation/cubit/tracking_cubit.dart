import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/partner_location_sync_service.dart';
import '../../../orders/domain/usecases/add_service_booking_history.dart';
import '../../../orders/domain/usecases/complete_service_booking.dart';
import '../../domain/entities/active_tracking.dart';
import '../../domain/usecases/get_active_tracking.dart';

part 'tracking_state.dart';

class TrackingCubit extends Cubit<TrackingState> {
  TrackingCubit(
    this._getActiveTracking,
    this._addServiceBookingHistory,
    this._completeServiceBooking,
    this._locationSyncService,
  ) : super(const TrackingInitial());

  final GetActiveTracking _getActiveTracking;
  final AddServiceBookingHistory _addServiceBookingHistory;
  final CompleteServiceBooking _completeServiceBooking;
  final PartnerLocationSyncService _locationSyncService;

  Future<void> load() async {
    emit(const TrackingLoading());
    try {
      final tracking = await _getActiveTracking();
      if (tracking.status.toLowerCase() == 'on_the_way' &&
          !_hasHistory(tracking, 'arrival')) {
        _locationSyncService.startBookingLocationSync(tracking.id);
      } else {
        _locationSyncService.stopBookingLocationSync();
      }
      emit(TrackingLoaded(tracking));
    } on Failure catch (error) {
      emit(TrackingError(error.message));
    } catch (_) {
      emit(const TrackingError('Tracking belum bisa dimuat.'));
    }
  }

  Future<void> markArrived(int id) async {
    await _action(
      action: () async {
        await _addServiceBookingHistory(
          id: id,
          title: 'Mitra sampai di lokasi',
          description: 'Mitra sudah tiba di alamat pasien.',
          treatmentType: 'arrival',
        );
        _locationSyncService.stopBookingLocationSync(bookingId: id);
      },
    );
  }

  Future<void> startTreatment(int id) async {
    await _action(
      action: () async {
        await _addServiceBookingHistory(
          id: id,
          title: 'Penanganan pasien dimulai',
          description: 'Mitra mulai melakukan pemeriksaan dan penanganan pasien.',
          treatmentType: 'treatment_started',
        );
      },
    );
  }

  Future<void> complete(int id) async {
    await _action(
      action: () async {
        await _completeServiceBooking(id);
        _locationSyncService.stopBookingLocationSync(bookingId: id);
      },
    );
  }

  Future<void> _action({
    required Future<void> Function() action,
  }) async {
    final current = state;

    try {
      await action();
      await load();
    } on Failure catch (error) {
      emit(TrackingError(error.message));
      if (current is TrackingLoaded) emit(current);
    } catch (_) {
      emit(const TrackingError('Aksi tracking belum bisa diproses.'));
      if (current is TrackingLoaded) emit(current);
    }
  }

  bool _hasHistory(ActiveTracking tracking, String marker) {
    final normalizedMarker = marker.toLowerCase();
    final readableMarker = normalizedMarker.replaceAll('_', ' ');
    return tracking.histories.any((history) {
      final treatmentType = history.treatmentType.toLowerCase();
      final title = history.title.toLowerCase();
      final notes = history.notes.toLowerCase();
      return treatmentType == normalizedMarker ||
          title.contains(readableMarker) ||
          notes.contains(readableMarker) ||
          (normalizedMarker == 'arrival' &&
              (title.contains('sampai') || title.contains('tiba'))) ||
          (normalizedMarker == 'treatment_started' &&
              title.contains('penanganan'));
    });
  }
}
