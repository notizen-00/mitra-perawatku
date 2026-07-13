import '../entities/partner_service.dart';
import '../repositories/partner_services_repository.dart';

class GetPartnerServices {
  const GetPartnerServices(this.repository);

  final PartnerServicesRepository repository;

  Future<List<PartnerService>> call() => repository.getServices();
}
