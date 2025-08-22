String getTimezoneOffsetFormatted() {
  final now = DateTime.now();
  final duration = now.timeZoneOffset;
  final sign = duration.isNegative ? '-' : '+';
  final hours = duration.inHours.abs().toString().padLeft(2, '0');
  final minutes = (duration.inMinutes.abs() % 60).toString().padLeft(2, '0');
  return '$sign$hours:$minutes';
}

DateTime parseUtc(String s) {
  final hasTz = RegExp(r'(Z|[+\-]\d{2}:\d{2})$').hasMatch(s);
  final normalized = hasTz ? s : '${s}Z'; // treat as UTC if no TZ suffix
  return DateTime.parse(normalized);      // returns a UTC DateTime
}