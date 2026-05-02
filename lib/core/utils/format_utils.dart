import 'package:intl/intl.dart';

class FormatUtils {
  FormatUtils._();

  static String date(String iso, {String? locale}) {
    final d = DateTime.parse('${iso}T00:00:00');
    return DateFormat.yMMMMEEEEd(locale).format(d);
  }

  static String duration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h}h ${m}m';
  }

  static String volume(double kg) {
    if (kg >= 1000) return '${(kg / 1000).toStringAsFixed(1)}K kg';
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

  static String longDate(String iso, {String? locale}) {
    final d = DateTime.parse('${iso}T00:00:00');
    return DateFormat.yMMMMEEEEd(locale).format(d);
  }

  static String monthYear(String iso, {String? locale}) {
    final d = DateTime.parse('${iso}T00:00:00');
    return DateFormat.yMMMM(locale).format(d);
  }
}
