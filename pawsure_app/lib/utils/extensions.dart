extension DateTimeExtension on DateTime {
  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  String toFormattedString() {
    return '${_months[month - 1]} $day, $year';
  }

  String toTimeString() {
    final period = hour >= 12 ? 'pm' : 'am';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final minutes = minute.toString().padLeft(2, '0');
    return '$displayHour:$minutes $period';
  }

  String toFullDateTimeString() {
    final period = hour >= 12 ? 'pm' : 'am';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final minutes = minute.toString().padLeft(2, '0');
    return '${_months[month - 1]} $day, $year $displayHour:$minutes $period';
  }

  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}

extension StringExtension on String {
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  bool get isValidPassword {
    return length >= 8;
  }

  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

extension NumExtension on num {
  String toWeightString() {
    return '${toStringAsFixed(1)} kg';
  }

  String toDistanceString() {
    return '${toStringAsFixed(2)} km';
  }
}
