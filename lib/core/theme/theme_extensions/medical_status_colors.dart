import 'package:flutter/material.dart';

@immutable
class MedicalStatusColors extends ThemeExtension<MedicalStatusColors> {
  const MedicalStatusColors({
    required this.available,
    required this.busy,
    required this.offline,
    required this.success,
    required this.warning,
    required this.info,
  });

  final Color available;
  final Color busy;
  final Color offline;
  final Color success;
  final Color warning;
  final Color info;

  @override
  MedicalStatusColors copyWith({
    Color? available,
    Color? busy,
    Color? offline,
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return MedicalStatusColors(
      available: available ?? this.available,
      busy: busy ?? this.busy,
      offline: offline ?? this.offline,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  MedicalStatusColors lerp(
    ThemeExtension<MedicalStatusColors>? other,
    double t,
  ) {
    if (other is! MedicalStatusColors) {
      return this;
    }

    return MedicalStatusColors(
      available: Color.lerp(available, other.available, t)!,
      busy: Color.lerp(busy, other.busy, t)!,
      offline: Color.lerp(offline, other.offline, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}
