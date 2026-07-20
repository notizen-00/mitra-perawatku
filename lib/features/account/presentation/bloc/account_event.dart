part of 'account_bloc.dart';

sealed class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

final class AccountStarted extends AccountEvent {
  const AccountStarted();
}

final class AccountRefreshRequested extends AccountEvent {
  const AccountRefreshRequested();
}

final class AccountMenuSelected extends AccountEvent {
  const AccountMenuSelected(this.title);

  final String title;

  @override
  List<Object?> get props => [title];
}

final class AccountLogoutPressed extends AccountEvent {
  const AccountLogoutPressed();
}
