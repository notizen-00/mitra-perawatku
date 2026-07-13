import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/wallet_summary.dart';
import '../../domain/usecases/get_wallet_summary.dart';

part 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit(this._getWalletSummary) : super(const WalletInitial());

  final GetWalletSummary _getWalletSummary;

  Future<void> load() async {
    emit(const WalletLoading());
    try {
      emit(WalletLoaded(await _getWalletSummary()));
    } on Failure catch (error) {
      emit(WalletError(error.message));
    } catch (_) {
      emit(const WalletError('Wallet belum bisa dimuat.'));
    }
  }
}
