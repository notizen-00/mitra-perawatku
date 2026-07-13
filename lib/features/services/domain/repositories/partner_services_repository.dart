import '../entities/partner_service.dart';

abstract class PartnerServicesRepository {
  Future<List<PartnerService>> getServices();
}
