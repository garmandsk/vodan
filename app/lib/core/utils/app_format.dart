import 'package:intl/intl.dart';

class AppFormat {
  static String currency(num amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  static String dateTime(DateTime date) {
    return DateFormat('dd MMMM YYYY, HH:mm', 'id_ID').format(date);
  }

  static String shortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}