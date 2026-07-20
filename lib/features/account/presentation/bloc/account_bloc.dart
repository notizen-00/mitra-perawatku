import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/account_summary.dart';
import '../../domain/usecases/get_account.dart';
import '../../domain/usecases/logout_account.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc({
    required GetAccount getAccount,
    required LogoutAccount logoutAccount,
  })  : _getAccount = getAccount,
        _logoutAccount = logoutAccount,
        super(const AccountInitial()) {
    on<AccountStarted>(_onStarted);
    on<AccountRefreshRequested>(_onRefreshRequested);
    on<AccountMenuSelected>(_onMenuSelected);
    on<AccountLogoutPressed>(_onLogoutPressed);
  }

  final GetAccount _getAccount;
  final LogoutAccount _logoutAccount;

  Future<void> _onStarted(
    AccountStarted event,
    Emitter<AccountState> emit,
  ) async {
    await _load(emit, showLoading: true);
  }

  Future<void> _onRefreshRequested(
    AccountRefreshRequested event,
    Emitter<AccountState> emit,
  ) async {
    await _load(emit, showLoading: false);
  }

  void _onMenuSelected(
    AccountMenuSelected event,
    Emitter<AccountState> emit,
  ) {
    final current = state;
    if (current is AccountLoaded) {
      emit(AccountLoaded(current.summary, selectedMenu: event.title));
    }
  }

  Future<void> _onLogoutPressed(
    AccountLogoutPressed event,
    Emitter<AccountState> emit,
  ) async {
    final current = state;
    if (current is! AccountLoaded) return;

    emit(AccountLogoutInProgress(current.summary));
    await _logoutAccount();
    emit(const AccountLoggedOut());
  }

  Future<void> _load(
    Emitter<AccountState> emit, {
    required bool showLoading,
  }) async {
    if (showLoading) emit(const AccountLoading());

    try {
      emit(AccountLoaded(await _getAccount()));
    } on Failure catch (error) {
      emit(AccountFailure(error.message));
    } catch (_) {
      emit(const AccountFailure('Akun belum bisa dimuat.'));
    }
  }
}
