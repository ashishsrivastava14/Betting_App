import 'package:intl/intl.dart';

class AppUtils {
  /// Format amount in Indian ₹ format: ₹1,23,456
  static String formatCurrency(double amount) {
    if (amount < 0) return '-${formatCurrency(-amount)}';
    
    final intPart = amount.truncate();
    final decimalPart = amount - intPart;
    
    String result = '';
    String numStr = intPart.toString();
    
    if (numStr.length <= 3) {
      result = numStr;
    } else {
      result = numStr.substring(numStr.length - 3);
      numStr = numStr.substring(0, numStr.length - 3);
      while (numStr.length > 2) {
        result = '${numStr.substring(numStr.length - 2)},$result';
        numStr = numStr.substring(0, numStr.length - 2);
      }
      result = '$numStr,$result';
    }
    
    if (decimalPart > 0) {
      final dec = decimalPart.toStringAsFixed(2).substring(2);
      return '₹$result.$dec';
    }
    return '₹$result';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd MMM, hh:mm a').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String getCountdown(DateTime target) {
    final diff = target.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    if (days > 0) return '${days}d ${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h ${minutes}m ${seconds}s';
    return '${minutes}m ${seconds}s';
  }

  static String generateId(String prefix) {
    return '$prefix${DateTime.now().millisecondsSinceEpoch}';
  }
}
