part of 'partner_services_cubit.dart';

abstract class PartnerServicesState extends Equatable {
  const PartnerServicesState();
}

class PartnerServicesInitial extends PartnerServicesState {
  const PartnerServicesInitial();

  @override
  List<Object?> get props => [];
}

class PartnerServicesLoading extends PartnerServicesState {
  const PartnerServicesLoading();

  @override
  List<Object?> get props => [];
}

class PartnerServicesLoaded extends PartnerServicesState {
  const PartnerServicesLoaded(this.services);

  final List<PartnerService> services;

  @override
  List<Object?> get props => [services];
}

class PartnerServicesError extends PartnerServicesState {
  const PartnerServicesError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
