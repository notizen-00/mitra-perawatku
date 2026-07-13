import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/reverb_websocket_service.dart';
import '../../domain/entities/home_summary.dart';
import '../../domain/usecases/get_home_summary.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._getHomeSummary, this._reverb) : super(const HomeInitial());

  final GetHomeSummary _getHomeSummary;
  final ReverbWebSocketService _reverb;

  Future<void> load() async {
    _reverb.connectAndSubscribe();

    emit(const HomeLoading());

    try {
      final summary = await _getHomeSummary();
      emit(HomeLoaded(summary));
    } on Failure catch (error) {
      emit(HomeError(error.message));
    } catch (_) {
      emit(const HomeError('Terjadi kesalahan yang tidak terduga.'));
    }
  }
}
