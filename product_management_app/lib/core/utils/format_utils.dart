import 'package:intl/intl.dart';

class FormatUtils {
  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ').format(amount);
  }

  static String formatDate(DateTime date) {
    return date.toLocal().toString().split(' ')[0];
  }
}
