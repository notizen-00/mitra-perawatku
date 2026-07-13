part of 'tracking_cubit.dart';

abstract class TrackingState extends Equatable {
  const TrackingState();
}

class TrackingInitial extends TrackingState {
  const TrackingInitial();

  @override
  List<Object?> get props => [];
}

class TrackingLoading extends TrackingState {
  const TrackingLoading();

  @override
  List<Object?> get props => [];
}

class TrackingLoaded extends TrackingState {
  const TrackingLoaded(this.tracking);

  final ActiveTracking tracking;

  @override
  List<Object?> get props => [tracking];
}

class TrackingError extends TrackingState {
  const TrackingError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
