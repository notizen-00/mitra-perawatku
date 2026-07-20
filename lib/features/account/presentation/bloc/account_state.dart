part of 'account_bloc.dart';

sealed class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

final class AccountInitial extends AccountState {
  const AccountInitial();
}

final class AccountLoading extends AccountState {
  const AccountLoading();
}

final class AccountLoaded extends AccountState {
  const AccountLoaded(this.summary, {this.selectedMenu, this.message});

  final AccountSummary summary;
  final String? selectedMenu;
  final String? message;

  @override
  List<Object?> get props => [summary, selectedMenu, message];
}

final class AccountSaving extends AccountState {
  const AccountSaving(this.summary);

  final AccountSummary summary;

  @override
  List<Object?> get props => [summary];
}

final class AccountFailure extends AccountState {
  const AccountFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class AccountLogoutInProgress extends AccountState {
  const AccountLogoutInProgress(this.summary);

  final AccountSummary summary;

  @override
  List<Object?> get props => [summary];
}

final class AccountLoggedOut extends AccountState {
  const AccountLoggedOut();
}
