import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static final DateFormat _shortDate = DateFormat('dd/MM');
  static final DateFormat _shortDateTime = DateFormat('dd/MM HH:mm');

  static String shortDate(DateTime value) => _shortDate.format(value);
  static String shortDateTime(DateTime value) => _shortDateTime.format(value);
}
