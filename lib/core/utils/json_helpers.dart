List<Map<String, dynamic>> jsonList(Map<String, dynamic> response) {
  final data = response['data'];
  if (data is List) return data.whereType<Map<String, dynamic>>().toList();
  if (data is Map<String, dynamic> && data['data'] is List) {
    return (data['data'] as List).whereType<Map<String, dynamic>>().toList();
  }
  return const [];
}

Map<String, dynamic>? jsonObject(Object? value) {
  if (value is Map<String, dynamic>) return value;
  return null;
}

int asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double asDouble(Object? value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

String displayTime(Object? value) {
  final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (date == null) return '-';

  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute WIB';
}

String formatCurrency(double value) {
  final raw = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < raw.length; i++) {
    final reverseIndex = raw.length - i;
    buffer.write(raw[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write('.');
  }
  return 'Rp $buffer';
}
