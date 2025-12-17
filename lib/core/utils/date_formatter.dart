import 'package:intl/intl.dart';

class DateFormatter {
  // Format: Jan 15, 2024
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  // Format: January 15, 2024
  static String formatLongDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }
  
  // Format: 15/01/2024
  static String formatNumericDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  // Format: Jan 15
  static String formatMonthDay(DateTime date) {
    return DateFormat('MMM dd').format(date);
  }
  
  // Format: 3:30 PM
  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }
  
  // Format: Jan 15, 2024 3:30 PM
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy h:mm a').format(date);
  }
  
  // Format date range: Jan 15 - Jan 20, 2024
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${formatMonthDay(start)} - ${formatShortDate(end)}';
    } else if (start.year == end.year) {
      return '${formatMonthDay(start)} - ${formatShortDate(end)}';
    } else {
      return '${formatShortDate(start)} - ${formatShortDate(end)}';
    }
  }
  
  // Get relative time (e.g., "2 hours ago", "Yesterday")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }
  
  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }
  
  // Check if date is in the past
  static bool isPast(DateTime date) {
    return date.isBefore(DateTime.now());
  }
  
  // Check if date is in the future
  static bool isFuture(DateTime date) {
    return date.isAfter(DateTime.now());
  }
  
  // Get days until date
  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    return difference.inDays;
  }
  
  // Parse date from string
  static DateTime? parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
