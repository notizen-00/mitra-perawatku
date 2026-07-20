import 'package:equatable/equatable.dart';

class HomeSummary extends Equatable {
  const HomeSummary({
    required this.partnerName,
    required this.profilePhotoUrl,
    required this.profession,
    required this.verificationStatus,
    required this.activeOrders,
    required this.todayIncome,
    required this.todayOrders,
    required this.rating,
    required this.walletBalance,
    required this.pendingIncome,
    required this.unreadNotifications,
    required this.isAvailable,
    required this.activeService,
    required this.incomingOrders,
    required this.todaySchedules,
    required this.recentActivities,
  });

  final String partnerName;
  final String profilePhotoUrl;
  final String profession;
  final String verificationStatus;
  final int activeOrders;
  final double todayIncome;
  final int todayOrders;
  final double rating;
  final double walletBalance;
  final double pendingIncome;
  final int unreadNotifications;
  final bool isAvailable;
  final ActiveService activeService;
  final List<PartnerOrder> incomingOrders;
  final List<ScheduleItem> todaySchedules;
  final List<ActivityItem> recentActivities;

  HomeSummary copyWith({
    String? partnerName,
    String? profilePhotoUrl,
    String? profession,
    String? verificationStatus,
    int? activeOrders,
    double? todayIncome,
    int? todayOrders,
    double? rating,
    double? walletBalance,
    double? pendingIncome,
    int? unreadNotifications,
    bool? isAvailable,
    ActiveService? activeService,
    List<PartnerOrder>? incomingOrders,
    List<ScheduleItem>? todaySchedules,
    List<ActivityItem>? recentActivities,
  }) {
    return HomeSummary(
      partnerName: partnerName ?? this.partnerName,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      profession: profession ?? this.profession,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      activeOrders: activeOrders ?? this.activeOrders,
      todayIncome: todayIncome ?? this.todayIncome,
      todayOrders: todayOrders ?? this.todayOrders,
      rating: rating ?? this.rating,
      walletBalance: walletBalance ?? this.walletBalance,
      pendingIncome: pendingIncome ?? this.pendingIncome,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      isAvailable: isAvailable ?? this.isAvailable,
      activeService: activeService ?? this.activeService,
      incomingOrders: incomingOrders ?? this.incomingOrders,
      todaySchedules: todaySchedules ?? this.todaySchedules,
      recentActivities: recentActivities ?? this.recentActivities,
    );
  }

  @override
  List<Object?> get props => [
    partnerName,
    profilePhotoUrl,
    profession,
    verificationStatus,
    activeOrders,
    todayIncome,
    todayOrders,
    rating,
    isAvailable,
    walletBalance,
    pendingIncome,
    unreadNotifications,
    activeService,
    incomingOrders,
    todaySchedules,
    recentActivities,
  ];
}

class ActiveService extends Equatable {
  const ActiveService({
    required this.title,
    required this.status,
    required this.patientName,
    required this.etaMinutes,
    required this.distanceKm,
  });

  final String title;
  final String status;
  final String patientName;
  final int etaMinutes;
  final double distanceKm;

  @override
  List<Object?> get props => [title, status, patientName, etaMinutes, distanceKm];
}

class PartnerOrder extends Equatable {
  const PartnerOrder({
    required this.id,
    required this.bookingCode,
    required this.patientName,
    required this.serviceName,
    required this.status,
    required this.scheduledAt,
    required this.distanceKm,
    required this.totalAmount,
    required this.paymentStatus,
    required this.addressLabel,
    required this.addressText,
    required this.latitude,
    required this.longitude,
  });

  final int id;
  final String bookingCode;
  final String patientName;
  final String serviceName;
  final String status;
  final String scheduledAt;
  final double distanceKm;
  final double totalAmount;
  final String paymentStatus;
  final String addressLabel;
  final String addressText;
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [
    id,
    bookingCode,
    patientName,
    serviceName,
    status,
    scheduledAt,
    distanceKm,
    totalAmount,
    paymentStatus,
    addressLabel,
    addressText,
    latitude,
    longitude,
  ];
}

class ScheduleItem extends Equatable {
  const ScheduleItem({
    required this.time,
    required this.title,
    required this.caption,
    required this.isCurrent,
  });

  final String time;
  final String title;
  final String caption;
  final bool isCurrent;

  @override
  List<Object?> get props => [time, title, caption, isCurrent];
}

class ActivityItem extends Equatable {
  const ActivityItem({
    required this.title,
    required this.caption,
    required this.type,
  });

  final String title;
  final String caption;
  final String type;

  @override
  List<Object?> get props => [title, caption, type];
}
