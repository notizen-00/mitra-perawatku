import '../../../../core/config/api_endpoints.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/auth_session.dart';
import '../../../auth/data/models/auth_user_model.dart';
import '../../domain/entities/home_summary.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl(this._apiClient, this._session);

  final ApiClient _apiClient;
  final AuthSession _session;

  @override
  Future<HomeSummary> getHomeSummary() async {
    try {
      final meResponse = await _apiClient.get(ApiEndpoints.me);
      final userJson = _extractObject(meResponse['data']) ?? meResponse;
      final user = AuthUserModel.fromJson(userJson);
      await _session.save(
        token: _session.token ?? '',
        userId: user.id,
        user: user,
      );

      final bookingsResponse = await _apiClient.get(
        ApiEndpoints.serviceBookings,
        queryParameters: {'assigned_partner_user_id': user.id, 'per_page': 20},
      );
      final notificationResponse = await _apiClient.get(
        ApiEndpoints.notifications,
        queryParameters: {
          'user_id': user.id,
          'status': 'unread',
          'per_page': 50,
        },
      );

      final bookings = _extractList(bookingsResponse);
      final notifications = _extractList(notificationResponse)
          .where((item) => _asInt(item['user_id']) == user.id)
          .toList();
      final profile = user.partnerProfile;

      return HomeSummary(
        partnerName: user.name.isEmpty ? 'Mitra Perawatku' : user.name,
        profilePhotoUrl: userJson['profile_photo_url']?.toString() ?? '',
        profession: _professionLabel(profile?.profession),
        verificationStatus: profile?.verificationStatus ?? 'pending',
        activeOrders: bookings.where(_isActiveBooking).length,
        todayIncome: _sumTodayIncome(bookings),
        todayOrders: bookings.where(_isTodayBooking).length,
        rating: 0,
        walletBalance: _walletBalance(bookings),
        pendingIncome: _pendingIncome(bookings),
        unreadNotifications: notifications.length,
        isAvailable: profile?.isAvailable ?? false,
        activeService: _activeService(bookings),
        incomingOrders: bookings
            .where(_isIncomingBooking)
            .map(_partnerOrder)
            .take(5)
            .toList(),
        todaySchedules: bookings
            .where(_isTodayBooking)
            .map(_scheduleItem)
            .take(5)
            .toList(),
        recentActivities: _recentActivities(bookings, notifications),
      );
    } on ApiException catch (error) {
      throw _mapApiException(error);
    } on FormatException catch (error) {
      throw ServerFailure(error.message);
    } on Exception {
      throw const ServerFailure();
    }
  }

  ActiveService _activeService(List<Map<String, dynamic>> bookings) {
    final booking = bookings.cast<Map<String, dynamic>?>().firstWhere(
      (item) => item != null && _isActiveBooking(item),
      orElse: () => null,
    );

    if (booking == null) {
      return const ActiveService(
        title: 'Belum ada layanan aktif',
        status: 'idle',
        patientName: 'Menunggu order baru',
        etaMinutes: 0,
        distanceKm: 0,
      );
    }

    return ActiveService(
      title: _serviceName(booking),
      status: booking['status']?.toString() ?? 'pending',
      patientName: _patientName(booking),
      etaMinutes: _etaMinutes(booking),
      distanceKm: _distanceKm(booking),
    );
  }

  PartnerOrder _partnerOrder(Map<String, dynamic> booking) {
    return PartnerOrder(
      id: _asInt(booking['id']),
      bookingCode: booking['booking_code']?.toString() ?? '-',
      patientName: _patientName(booking),
      serviceName: _serviceName(booking),
      status: booking['status']?.toString() ?? 'pending',
      scheduledAt: _displayTime(
        booking['scheduled_at'] ??
            booking['schedule_start_at'] ??
            booking['created_at'],
      ),
      distanceKm: _distanceKm(booking),
      totalAmount: _asDouble(booking['total_amount']),
      paymentStatus: _paymentStatus(booking),
    );
  }

  ScheduleItem _scheduleItem(Map<String, dynamic> booking) {
    return ScheduleItem(
      time: _displayTime(
        booking['scheduled_at'] ??
            booking['schedule_start_at'] ??
            booking['created_at'],
      ),
      title: _serviceName(booking),
      caption: '${_patientName(booking)} - ${booking['status'] ?? 'pending'}',
      isCurrent: _isActiveBooking(booking),
    );
  }

  List<ActivityItem> _recentActivities(
    List<Map<String, dynamic>> bookings,
    List<Map<String, dynamic>> notifications,
  ) {
    final items = <ActivityItem>[
      for (final notification in notifications.take(3))
        ActivityItem(
          title: notification['title']?.toString() ?? 'Notifikasi',
          caption: notification['body']?.toString() ?? '',
          type: notification['type']?.toString() ?? 'notification',
        ),
      for (final booking in bookings.where(_hasBalanceTransaction).take(2))
        ActivityItem(
          title: 'Saldo layanan masuk',
          caption:
              '${booking['booking_code'] ?? '-'} - ${_serviceName(booking)}',
          type: 'wallet',
        ),
    ];

    if (items.isEmpty) {
      return const [
        ActivityItem(
          title: 'Belum ada aktivitas',
          caption: 'Aktivitas order dan notifikasi akan tampil di sini.',
          type: 'empty',
        ),
      ];
    }

    return items;
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }

    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is List) {
        return nested.whereType<Map<String, dynamic>>().toList();
      }
    }

    return const [];
  }

  Map<String, dynamic>? _extractObject(Object? value) {
    if (value is Map<String, dynamic>) return value;
    return null;
  }

  bool _isIncomingBooking(Map<String, dynamic> booking) {
    final status = booking['status']?.toString();
    return status == 'pending' ||
        status == 'scheduled' ||
        status == 'confirmed';
  }

  bool _isActiveBooking(Map<String, dynamic> booking) {
    final status = booking['status']?.toString();
    return status == 'confirmed' ||
        status == 'scheduled' ||
        status == 'on_the_way';
  }

  bool _isTodayBooking(Map<String, dynamic> booking) {
    final value =
        booking['scheduled_at'] ??
        booking['schedule_start_at'] ??
        booking['created_at'];
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    final now = DateTime.now();
    return date != null &&
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _hasBalanceTransaction(Map<String, dynamic> booking) {
    return booking['partner_balance_transaction'] is Map<String, dynamic>;
  }

  double _walletBalance(List<Map<String, dynamic>> bookings) {
    final balances = bookings
        .map(
          (booking) => _extractObject(booking['partner_balance_transaction']),
        )
        .whereType<Map<String, dynamic>>()
        .map(
          (transaction) =>
              _asDouble(transaction['balance_after'] ?? transaction['balance']),
        )
        .where((value) => value > 0)
        .toList();

    if (balances.isNotEmpty) {
      return balances.first;
    }

    return bookings
        .where(_hasBalanceTransaction)
        .fold<double>(0, (total, booking) => total + _bookingCredit(booking));
  }

  double _sumTodayIncome(List<Map<String, dynamic>> bookings) {
    return bookings
        .where(_isTodayBooking)
        .where(_hasBalanceTransaction)
        .fold<double>(0, (total, booking) => total + _bookingCredit(booking));
  }

  double _pendingIncome(List<Map<String, dynamic>> bookings) {
    return bookings
        .where((booking) => _paymentStatus(booking) == 'paid')
        .where((booking) => !_hasBalanceTransaction(booking))
        .fold<double>(
          0,
          (total, booking) => total + _asDouble(booking['total_amount']),
        );
  }

  double _bookingCredit(Map<String, dynamic> booking) {
    final transaction = _extractObject(booking['partner_balance_transaction']);
    if (transaction == null) return 0;

    return _asDouble(
      transaction['amount'] ??
          transaction['credit'] ??
          transaction['total_amount'] ??
          booking['total_amount'],
    );
  }

  String _serviceName(Map<String, dynamic> booking) {
    final service = _extractObject(booking['service']);
    return service?['name']?.toString() ?? 'Layanan kesehatan';
  }

  String _patientName(Map<String, dynamic> booking) {
    final patient = _extractObject(booking['patient']);
    final member = _extractObject(booking['patient_member']);
    return patient?['name']?.toString() ??
        member?['name']?.toString() ??
        'Pasien';
  }

  String _paymentStatus(Map<String, dynamic> booking) {
    final payment = _extractObject(booking['payment']);
    return payment?['status']?.toString() ?? 'unpaid';
  }

  double _distanceKm(Map<String, dynamic> booking) {
    final matchmaking = _extractObject(booking['matchmaking']);
    return _asDouble(
      booking['distance_km'] ??
          matchmaking?['distance_km'] ??
          booking['distance'],
    );
  }

  int _etaMinutes(Map<String, dynamic> booking) {
    final eta = booking['eta_minutes'] ?? booking['estimated_arrival_minutes'];
    if (eta != null) return _asInt(eta);

    final distance = _distanceKm(booking);
    if (distance <= 0) return 0;
    return (distance / 25 * 60).ceil();
  }

  String _displayTime(Object? value) {
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (date == null) return '-';

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute WIB';
  }

  String _professionLabel(String? profession) {
    return switch (profession) {
      'dokter' => 'Dokter Homecare',
      'bidan' => 'Bidan Homecare',
      'perawat' => 'Perawat Homecare',
      null || '' => 'Mitra Kesehatan',
      _ => profession,
    };
  }

  Failure _mapApiException(ApiException error) {
    return switch (error.statusCode) {
      0 => NetworkFailure(error.message),
      401 || 403 => UnauthorizedFailure(error.message),
      422 => ValidationFailure(error.message),
      _ => ServerFailure(error.message),
    };
  }

  int _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _asDouble(Object? value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
