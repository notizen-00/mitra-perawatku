import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/account_profile_update.dart';
import '../../domain/entities/account_summary.dart';
import '../../domain/usecases/delete_account_profile_photo.dart';
import '../../domain/usecases/get_account.dart';
import '../../domain/usecases/logout_account.dart';
import '../../domain/usecases/update_account_profile.dart';
import '../../domain/usecases/upload_account_profile_photo.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc({
    required GetAccount getAccount,
    required UpdateAccountProfile updateAccountProfile,
    required UploadAccountProfilePhoto uploadProfilePhoto,
    required DeleteAccountProfilePhoto deleteProfilePhoto,
    required LogoutAccount logoutAccount,
  })  : _getAccount = getAccount,
        _updateAccountProfile = updateAccountProfile,
        _uploadProfilePhoto = uploadProfilePhoto,
        _deleteProfilePhoto = deleteProfilePhoto,
        _logoutAccount = logoutAccount,
        super(const AccountInitial()) {
    on<AccountStarted>(_onStarted);
    on<AccountRefreshRequested>(_onRefreshRequested);
    on<AccountMenuSelected>(_onMenuSelected);
    on<AccountProfileSubmitted>(_onProfileSubmitted);
    on<AccountProfilePhotoSelected>(_onProfilePhotoSelected);
    on<AccountProfilePhotoDeleted>(_onProfilePhotoDeleted);
    on<AccountLogoutPressed>(_onLogoutPressed);
  }

  final GetAccount _getAccount;
  final UpdateAccountProfile _updateAccountProfile;
  final UploadAccountProfilePhoto _uploadProfilePhoto;
  final DeleteAccountProfilePhoto _deleteProfilePhoto;
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

  Future<void> _onProfileSubmitted(
    AccountProfileSubmitted event,
    Emitter<AccountState> emit,
  ) async {
    await _mutateAccount(
      emit,
      action: () => _updateAccountProfile(event.input),
      successMessage: 'Profil berhasil diperbarui.',
    );
  }

  Future<void> _onProfilePhotoSelected(
    AccountProfilePhotoSelected event,
    Emitter<AccountState> emit,
  ) async {
    await _mutateAccount(
      emit,
      action: () => _uploadProfilePhoto(event.filePath),
      successMessage: 'Foto profil berhasil diperbarui.',
    );
  }

  Future<void> _onProfilePhotoDeleted(
    AccountProfilePhotoDeleted event,
    Emitter<AccountState> emit,
  ) async {
    await _mutateAccount(
      emit,
      action: _deleteProfilePhoto,
      successMessage: 'Foto profil berhasil dihapus.',
    );
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

  Future<void> _mutateAccount(
    Emitter<AccountState> emit, {
    required Future<AccountSummary> Function() action,
    required String successMessage,
  }) async {
    final current = state;
    if (current is! AccountLoaded) return;

    emit(AccountSaving(current.summary));
    try {
      emit(AccountLoaded(await action(), message: successMessage));
    } on Failure catch (error) {
      emit(AccountLoaded(current.summary, message: error.message));
    } catch (_) {
      emit(AccountLoaded(current.summary, message: 'Perubahan belum tersimpan.'));
    }
  }
}
