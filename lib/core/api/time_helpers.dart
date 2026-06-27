class TimeRange {
  final String start; // ISO 8601 UTC string
  final String end;   // ISO 8601 UTC string

  TimeRange({required this.start, required this.end});
}

class TimeHelpers {
  /// Returns current UTC time as ISO 8601 string
  static String get nowUtc =>
      DateTime.now().toUtc().toIso8601String();

  /// Last 1 hour
  static TimeRange get lastHour {
    final end = DateTime.now().toUtc();
    final start = end.subtract(const Duration(hours: 1));
    return TimeRange(
      start: start.toIso8601String(),
      end: end.toIso8601String(),
    );
  }

  /// Last 24 hours
  static TimeRange get last24Hours {
    final end = DateTime.now().toUtc();
    final start = end.subtract(const Duration(hours: 24));
    return TimeRange(
      start: start.toIso8601String(),
      end: end.toIso8601String(),
    );
  }

  /// Last 7 days
  static TimeRange get last7Days {
    final end = DateTime.now().toUtc();
    final start = end.subtract(const Duration(days: 7));
    return TimeRange(
      start: start.toIso8601String(),
      end: end.toIso8601String(),
    );
  }

  /// Last 30 days
  static TimeRange get last30Days {
    final end = DateTime.now().toUtc();
    final start = end.subtract(const Duration(days: 30));
    return TimeRange(
      start: start.toIso8601String(),
      end: end.toIso8601String(),
    );
  }
}
