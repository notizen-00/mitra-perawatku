import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/partner_location_sync_service.dart';
import '../../domain/entities/active_tracking.dart';
import '../../domain/usecases/get_active_tracking.dart';

part 'tracking_state.dart';

class TrackingCubit extends Cubit<TrackingState> {
  TrackingCubit(this._getActiveTracking, this._locationSyncService)
      : super(const TrackingInitial());

  final GetActiveTracking _getActiveTracking;
  final PartnerLocationSyncService _locationSyncService;

  Future<void> load() async {
    emit(const TrackingLoading());
    try {
      final tracking = await _getActiveTracking();
      if (tracking.status.toLowerCase() == 'on_the_way') {
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
}
