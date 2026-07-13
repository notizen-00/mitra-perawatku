import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/partner_service.dart';
import '../../domain/usecases/get_partner_services.dart';

part 'partner_services_state.dart';

class PartnerServicesCubit extends Cubit<PartnerServicesState> {
  PartnerServicesCubit(this._getPartnerServices)
    : super(const PartnerServicesInitial());

  final GetPartnerServices _getPartnerServices;

  Future<void> load() async {
    emit(const PartnerServicesLoading());
    try {
      emit(PartnerServicesLoaded(await _getPartnerServices()));
    } on Failure catch (error) {
      emit(PartnerServicesError(error.message));
    } catch (_) {
      emit(const PartnerServicesError('Layanan belum bisa dimuat.'));
    }
  }
}
