/// Indonesian date and period formatting helpers (offline, zero locale init required).
abstract final class AppDateFormatter {
  static const List<String> _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<String> _dayNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static String monthYear(DateTime date) {
    return '${_shortMonths[date.month - 1]} ${date.year}';
  }

  static String shortDate(DateTime date) {
    return '${date.day} ${_shortMonths[date.month - 1]} ${date.year}';
  }

  static String time24(DateTime date) {
    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  /// Returns `Hari ini, 14:20`, `Kemarin, 09:15`, or `22 Nov 2026, 09:15`.
  static String relativeDateTime(DateTime date, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    final target = DateTime(date.year, date.month, date.day);
    final diffDays = today.difference(target).inDays;

    if (diffDays == 0) return 'Hari ini, ${time24(date)}';
    if (diffDays == 1) return 'Kemarin, ${time24(date)}';
    return '${shortDate(date)}, ${time24(date)}';
  }

  /// Returns group header label: `Hari ini, 24 Nov 2026`, `Kemarin, 23 Nov 2026`,
  /// or `Sabtu, 21 Nov 2026`.
  static String sectionHeader(DateTime date, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    final target = DateTime(date.year, date.month, date.day);
    final diffDays = today.difference(target).inDays;

    if (diffDays == 0) return 'Hari ini, ${shortDate(date)}';
    if (diffDays == 1) return 'Kemarin, ${shortDate(date)}';
    return '${_dayNames[date.weekday - 1]}, ${shortDate(date)}';
  }
}
