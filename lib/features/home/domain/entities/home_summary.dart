import 'package:equatable/equatable.dart';

class HomeSummary extends Equatable {
  const HomeSummary({
    required this.title,
    required this.subtitle,
    required this.activeOrders,
    required this.todayIncome,
    required this.todayOrders,
    required this.rating,
    required this.upcomingSchedule,
    required this.recentActivity,
    required this.isAvailable,
  });

  final String title;
  final String subtitle;
  final int activeOrders;
  final double todayIncome;
  final int todayOrders;
  final double rating;
  final String upcomingSchedule;
  final String recentActivity;
  final bool isAvailable;

  @override
  List<Object?> get props => [
    title,
    subtitle,
    activeOrders,
    todayIncome,
    todayOrders,
    rating,
    upcomingSchedule,
    recentActivity,
    isAvailable,
  ];
}
