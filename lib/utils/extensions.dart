import 'package:intl/intl.dart';

import 'date_formatter.dart';

extension WeightFormatting on double {
  String get asDecimal => NumberFormat.decimalPatternDigits(
        locale: 'pt_BR',
        decimalDigits: 1,
      ).format(this);

  String get asSignedDecimal {
    final absolute = abs().asDecimal;
    if (this > 0) {
      return '+$absolute';
    }
    if (this < 0) {
      return '-$absolute';
    }
    return absolute;
  }

  String get asKg => '$asDecimal kg';
  String get asSignedKg => '$asSignedDecimal kg';
}

extension DateFormatting on DateTime {
  String get asShortDate => DateFormatter.shortDate(this);
  String get asShortDateTime => DateFormatter.shortDateTime(this);
  String get asFullDate => DateFormatter.fullDate(this);
  String get asTime => DateFormatter.time(this);
}
