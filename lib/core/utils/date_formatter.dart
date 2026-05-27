import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String groupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';

    if (date.year == now.year) {
      return DateFormat('EEE, MMM d').format(date);
    }

    return DateFormat('MMM d, yyyy').format(date);
  }

  static String time(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String full(DateTime date) {
    return DateFormat('MMM d, yyyy').add_jm().format(date);
  }

  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inSeconds < 30) return 'Just now';
    if (diff.inMinutes < 1) return '${diff.inSeconds}s ago';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return DateFormat('MMM d').format(date);
  }
}
