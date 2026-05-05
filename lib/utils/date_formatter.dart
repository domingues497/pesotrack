import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static final DateFormat _shortDate = DateFormat('dd/MM', 'pt_BR');
  static final DateFormat _shortDateTime = DateFormat('dd/MM HH:mm', 'pt_BR');
  static final DateFormat _fullDate = DateFormat('dd/MM/yyyy', 'pt_BR');
  static final DateFormat _time = DateFormat('HH:mm', 'pt_BR');

  static String shortDate(DateTime value) => _shortDate.format(value);
  static String shortDateTime(DateTime value) => _shortDateTime.format(value);
  static String fullDate(DateTime value) => _fullDate.format(value);
  static String time(DateTime value) => _time.format(value);
}
