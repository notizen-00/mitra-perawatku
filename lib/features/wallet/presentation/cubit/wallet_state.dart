part of 'wallet_cubit.dart';

abstract class WalletState extends Equatable {
  const WalletState();
}

class WalletInitial extends WalletState {
  const WalletInitial();

  @override
  List<Object?> get props => [];
}

class WalletLoading extends WalletState {
  const WalletLoading();

  @override
  List<Object?> get props => [];
}

class WalletLoaded extends WalletState {
  const WalletLoaded(this.summary);

  final WalletSummary summary;

  @override
  List<Object?> get props => [summary];
}

class WalletError extends WalletState {
  const WalletError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
