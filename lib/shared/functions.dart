String getTimezoneOffsetFormatted() {
  final now = DateTime.now();
  final duration = now.timeZoneOffset;
  final sign = duration.isNegative ? '-' : '+';
  final hours = duration.inHours.abs().toString().padLeft(2, '0');
  final minutes = (duration.inMinutes.abs() % 60).toString().padLeft(2, '0');
  return '$sign$hours:$minutes';
}

