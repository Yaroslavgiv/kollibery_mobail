import 'package:intl/intl.dart';

class KFormatter {
  static String formatDate(DateTime? date) {
    date ??= DateTime.now();
    return DateFormat('dd.MM.yyyy').format(date);
  }

  static String formatCurrency(double amount,
      {String locale = 'ru_RU', String symbol = '₽'}) {
    return NumberFormat.currency(locale: locale, symbol: symbol).format(amount);
  }

  static String formatPhoneNumber(String phoneNumber) {
    // Russian phone number formatting logic
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11 && digits.startsWith('7')) {
      return '+7 (${digits.substring(1, 4)}) ${digits.substring(4, 7)}-${digits.substring(7, 9)}-${digits.substring(9)}';
    }
    return digits;
  }
}
