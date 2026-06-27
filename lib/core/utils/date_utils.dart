import 'package:timeago/timeago.dart' as timeago;

class SupaDateParser {
  /// Safely parses dynamic value into a [DateTime] object.
  /// Handles ISO-8601 Strings, Unix Timestamps (int/double), and null values.
  static DateTime? parse(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    if (value is int) {
      if (value < 10000000000) {
        // Value is likely in seconds (Unix timestamp)
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is String) {
      if (value.isEmpty) return null;
      // Try to parse string as int first (in case string contains timestamp)
      final timestamp = int.tryParse(value);
      if (timestamp != null) return parse(timestamp);
      
      return DateTime.tryParse(value);
    }

    return null;
  }

  /// Safely parses dynamic value and formats it as a relative "time ago" string.
  static String format(dynamic value, {String fallback = 'N/A'}) {
    final date = parse(value);
    if (date == null) return fallback;
    return timeago.format(date);
  }
}

