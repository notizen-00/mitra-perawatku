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

final class AccountProfileSubmitted extends AccountEvent {
  const AccountProfileSubmitted(this.input);

  final AccountProfileUpdate input;

  @override
  List<Object?> get props => [input];
}

final class AccountProfilePhotoSelected extends AccountEvent {
  const AccountProfilePhotoSelected(this.filePath);

  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

final class AccountProfilePhotoDeleted extends AccountEvent {
  const AccountProfilePhotoDeleted();
}

final class AccountLogoutPressed extends AccountEvent {
  const AccountLogoutPressed();
}
