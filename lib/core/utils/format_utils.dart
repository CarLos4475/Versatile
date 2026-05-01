class FormatUtils {
  FormatUtils._();

  static String date(String iso) {
    final d = DateTime.parse('${iso}T00:00:00');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = today.difference(d).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}';
  }

  static String duration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }

  static String volume(double kg) {
    if (kg >= 1000) return '${(kg / 1000).toStringAsFixed(1)}k kg';
    return '${kg.toStringAsFixed(0)} kg';
  }

  static String timer(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static String weight(double kg) {
    if (kg == kg.roundToDouble()) return kg.toInt().toString();
    return kg.toString();
  }

  static String longDate(String iso) {
    final d = DateTime.parse('${iso}T00:00:00');
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  static String monthYear(String iso) {
    final d = DateTime.parse('${iso}T00:00:00');
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[d.month - 1]} ${d.year}';
  }
}