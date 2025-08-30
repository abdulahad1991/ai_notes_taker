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

String formatScheduledTime(String scheduledTimeString) {
  try {
    final scheduledTime = parseUtc(scheduledTimeString).toLocal();
    /*final now = DateTime.now();
      final difference = scheduledTime.difference(now);

      if (difference.inDays > 0) {
        if (difference.inDays == 1) {
          return 'Tomorrow ${_formatTime(scheduledTime)}';
        } else if (difference.inDays < 7) {
          final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          return '${weekdays[scheduledTime.weekday - 1]} ${_formatTime(scheduledTime)}';
        } else {
          return '${scheduledTime.day}/${scheduledTime.month} ${_formatTime(scheduledTime)}';
        }
      } else if (difference.inHours > 0) {
        return 'Today ${_formatTime(scheduledTime)}';
      } else if (difference.inMinutes > 0) {
        return 'In ${difference.inMinutes}m';
      } else if (difference.inMinutes > -60) {
        return 'Late ${difference.inMinutes.abs()}m';
      } else {

      }*/
    return '${formatTimeDate(scheduledTime)}';
  } catch (e) {
    return scheduledTimeString;
  }
}



String formatTimeDate(DateTime time) {
  final hour = time.hour > 12 ? time.hour - 12 : time.hour == 0 ? 12 : time.hour;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute$period';
}

String formatTime(String? dateTimeString) {
  if (dateTimeString == null || dateTimeString.isEmpty) return 'N/A';
  try {
    final dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  } catch (e) {
    return 'N/A';
  }
}