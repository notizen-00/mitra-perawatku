class ApiEndpoints {
  ApiEndpoints._();

  static const mitraRegister = '/mitra/register';
  static const mitraLogin = '/mitra/login';
  static const doctorLogin = '/mitra/doctor/login';
  static const nurseLogin = '/mitra/nurse/login';
  static const pharmacyLogin = '/mitra/apotik/login';
  static const me = '/shared/me';
  static const logout = '/shared/logout';
  static const profilePhoto = '/shared/profile-photo';
  static const mitraProfile = '/mitra/profile';
  static const serviceApplications = '/mitra/service-applications';
  static const serviceBookings = '/mitra/service-bookings';
  static const consultations = '/mitra/consultations';
  static const notifications = '/shared/notifications';
  static const broadcastingAuth = '/broadcasting/auth';

  static String serviceBooking(int id) => '$serviceBookings/$id';
  static String acceptServiceBooking(int id) => '$serviceBookings/$id/accept';
  static String startJourney(int id) => '$serviceBookings/$id/start-journey';
  static String completeServiceBooking(int id) =>
      '$serviceBookings/$id/complete';
  static String serviceBookingHistories(int id) =>
      '$serviceBookings/$id/histories';
  static String serviceBookingStatus(int id) => '$serviceBookings/$id/status';
  static String consultation(int id) => '$consultations/$id';
  static String consultationStatus(int id) => '$consultations/$id/status';
  static String consultationMessages(int id) => '$consultations/$id/messages';
}
