import 'date_formatter.dart';

extension WeightFormatting on double {
  String get asKg => '${toStringAsFixed(1)} kg';
}

extension DateFormatting on DateTime {
  String get asShortDate => DateFormatter.shortDate(this);
  String get asShortDateTime => DateFormatter.shortDateTime(this);
}
