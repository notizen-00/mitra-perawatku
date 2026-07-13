import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/active_tracking.dart';
import '../../domain/usecases/get_active_tracking.dart';

part 'tracking_state.dart';

class TrackingCubit extends Cubit<TrackingState> {
  TrackingCubit(this._getActiveTracking) : super(const TrackingInitial());

  final GetActiveTracking _getActiveTracking;

  Future<void> load() async {
    emit(const TrackingLoading());
    try {
      emit(TrackingLoaded(await _getActiveTracking()));
    } on Failure catch (error) {
      emit(TrackingError(error.message));
    } catch (_) {
      emit(const TrackingError('Tracking belum bisa dimuat.'));
    }
  }
}
