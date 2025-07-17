import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  // ==================== FORMATTING ====================

  /// Formats date as "Jan 15, 2024"
  String get formatMediumDate => DateFormat('MMM dd, yyyy').format(this);

  /// Formats date as "January 15, 2024"
  String get formatLongDate => DateFormat('MMMM dd, yyyy').format(this);

  /// Formats date as "15/01/2024"
  String get formatShortDate => DateFormat('dd/MM/yyyy').format(this);

  /// Formats date as "2024-01-15"
  String get formatISODate => DateFormat('yyyy-MM-dd').format(this);

  /// Formats time as "2:30 PM"
  String get formatTime => DateFormat('h:mm a').format(this);

  /// Formats time as "14:30"
  String get formatTime24 => DateFormat('HH:mm').format(this);

  /// Formats as "Jan 15, 2024 at 2:30 PM"
  String get formatDateTime => DateFormat('MMM dd, yyyy \'at\' h:mm a').format(this);

  /// Formats as "Monday, January 15, 2024"
  String get formatFullDate => DateFormat('EEEE, MMMM dd, yyyy').format(this);

  /// Formats as "Mon, Jan 15"
  String get formatCompactDate => DateFormat('EEE, MMM dd').format(this);

  /// Custom format method
  String format(String pattern) => DateFormat(pattern).format(this);

  // ==================== RELATIVE TIME ====================

  /// Returns relative time like "2 hours ago", "in 3 days"
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.isNegative) {
      return _formatFutureTime(difference.abs());
    }

    return _formatPastTime(difference);
  }

  String _formatPastTime(Duration difference) {
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1 ? '1 day ago' : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? '1 hour ago' : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? '1 minute ago' : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  String _formatFutureTime(Duration difference) {
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'in 1 year' : 'in $years years';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'in 1 month' : 'in $months months';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1 ? 'in 1 day' : 'in ${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? 'in 1 hour' : 'in ${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? 'in 1 minute' : 'in ${difference.inMinutes} minutes';
    } else {
      return 'in a moment';
    }
  }

  // ==================== COMPARISONS ====================

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Check if date is this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) && isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if date is this month
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Check if date is this year
  bool get isThisYear {
    return year == DateTime.now().year;
  }

  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Check if it's weekend (Saturday or Sunday)
  bool get isWeekend => weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Check if it's weekday (Monday to Friday)
  bool get isWeekday => !isWeekend;

  // ==================== UTILITIES ====================

  /// Get start of day (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day (23:59:59.999)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Get start of week (Monday)
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return subtract(Duration(days: daysFromMonday)).startOfDay;
  }

  /// Get end of week (Sunday)
  DateTime get endOfWeek {
    final daysToSunday = 7 - weekday;
    return add(Duration(days: daysToSunday)).endOfDay;
  }

  /// Get start of month
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Get end of month
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  /// Get start of year
  DateTime get startOfYear => DateTime(year, 1, 1);

  /// Get end of year
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59, 999);

  /// Get age in years from this date
  int get ageInYears {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  /// Get days in current month
  int get daysInMonth => DateTime(year, month + 1, 0).day;

  /// Get day name (Monday, Tuesday, etc.)
  String get dayName => DateFormat('EEEE').format(this);

  /// Get short day name (Mon, Tue, etc.)
  String get shortDayName => DateFormat('EEE').format(this);

  /// Get month name (January, February, etc.)
  String get monthName => DateFormat('MMMM').format(this);

  /// Get short month name (Jan, Feb, etc.)
  String get shortMonthName => DateFormat('MMM').format(this);

  /// Get quarter of year (1-4)
  int get quarter => ((month - 1) / 3).floor() + 1;

  /// Get week of year
  int get weekOfYear {
    final firstJan = DateTime(year, 1, 1);
    final daysOffset = firstJan.weekday - 1;
    final firstWeek = firstJan.subtract(Duration(days: daysOffset));
    final diff = this.difference(firstWeek);
    return (diff.inDays / 7).floor() + 1;
  }

  // ==================== OPERATIONS ====================

  /// Add business days (excludes weekends)
  DateTime addBusinessDays(int days) {
    DateTime result = this;
    int addedDays = 0;

    while (addedDays < days) {
      result = result.add(const Duration(days: 1));
      if (result.isWeekday) {
        addedDays++;
      }
    }

    return result;
  }

  /// Subtract business days (excludes weekends)
  DateTime subtractBusinessDays(int days) {
    DateTime result = this;
    int subtractedDays = 0;

    while (subtractedDays < days) {
      result = result.subtract(const Duration(days: 1));
      if (result.isWeekday) {
        subtractedDays++;
      }
    }

    return result;
  }

  /// Get next occurrence of a specific weekday
  DateTime nextWeekday(int weekday) {
    assert(weekday >= 1 && weekday <= 7, 'Weekday must be between 1 (Monday) and 7 (Sunday)');

    int daysToAdd = weekday - this.weekday;
    if (daysToAdd <= 0) {
      daysToAdd += 7;
    }

    return add(Duration(days: daysToAdd));
  }

  /// Get previous occurrence of a specific weekday
  DateTime previousWeekday(int weekday) {
    assert(weekday >= 1 && weekday <= 7, 'Weekday must be between 1 (Monday) and 7 (Sunday)');

    int daysToSubtract = this.weekday - weekday;
    if (daysToSubtract <= 0) {
      daysToSubtract += 7;
    }

    return subtract(Duration(days: daysToSubtract));
  }

  /// Copy with specific components
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }

  // ==================== SMART FORMATTING ====================

  /// Smart format that chooses appropriate format based on context
  String get smartFormat {
    if (isToday) {
      return 'Today at ${formatTime}';
    } else if (isYesterday) {
      return 'Yesterday at ${formatTime}';
    } else if (isTomorrow) {
      return 'Tomorrow at ${formatTime}';
    } else if (isThisWeek) {
      return '${shortDayName} at ${formatTime}';
    } else if (isThisYear) {
      return formatCompactDate;
    } else {
      return formatMediumDate;
    }
  }

  /// Format for lists/feeds (compact but informative)
  String get listFormat {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inMinutes < 1) {
      return 'Now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d';
    } else if (isThisYear) {
      return formatCompactDate;
    } else {
      return format('MMM dd, yy');
    }
  }
}

// ==================== HELPER FUNCTIONS ====================

/// Parse common date formats
extension DateTimeParser on String {
  /// Try to parse various date formats
  DateTime? tryParseDateTime() {
    final formats = [
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd',
      'dd/MM/yyyy',
      'MM/dd/yyyy',
      'dd-MM-yyyy',
      'yyyy/MM/dd',
      'MMM dd, yyyy',
      'MMMM dd, yyyy',
    ];

    for (final format in formats) {
      try {
        return DateFormat(format).parse(this);
      } catch (e) {
        continue;
      }
    }

    // Try default DateTime.parse
    try {
      return DateTime.parse(this);
    } catch (e) {
      return null;
    }
  }
}

// // ==================== USAGE EXAMPLES ====================

// class DateTimeUsageExamples {
//   static void examples() {
//     final now = DateTime.now();
//     final birthday = DateTime(1990, 5, 15);
//     final future = DateTime.now().add(const Duration(days: 3));

//     // Formatting
//     print(now.formatMediumDate); // "Jan 15, 2024"
//     print(now.formatTime); // "2:30 PM"
//     print(now.formatDateTime); // "Jan 15, 2024 at 2:30 PM"
//     print(now.smartFormat); // "Today at 2:30 PM"

//     // Relative time
//     print(birthday.timeAgo); // "34 years ago"
//     print(future.timeAgo); // "in 3 days"

//     // Comparisons
//     print(now.isToday); // true
//     print(now.isWeekend); // depends on current day
//     print(birthday.isThisYear); // false

//     // Utilities
//     print(now.startOfDay); // Today at 00:00:00
//     print(now.ageInYears); // Age from now
//     print(now.dayName); // "Monday"
//     print(now.quarter); // 1, 2, 3, or 4

//     // Operations
//     final nextMonday = now.nextWeekday(DateTime.monday);
//     final fiveBizDaysLater = now.addBusinessDays(5);

//     // Parsing
//     final parsed = "2024-01-15".tryParseDateTime();
//     print(parsed?.formatMediumDate); // "Jan 15, 2024"
//   }
// }