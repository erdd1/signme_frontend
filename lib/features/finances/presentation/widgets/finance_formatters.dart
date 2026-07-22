import 'package:intl/intl.dart';

abstract final class FinanceFormatters {
  static final _fcfa = NumberFormat('#,###', 'fr_FR');

  static String fcfa(num value) => '${_fcfa.format(value)} FCFA';

  static String fcfaShort(num value) => '${_fcfa.format(value)} F';

  static String percent(double value) {
    final sign = value > 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)} %';
  }
}
