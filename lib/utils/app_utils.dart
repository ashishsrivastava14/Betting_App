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

  /// Local team logo asset paths
  static const Map<String, String> teamLogoAssets = {
    'India': 'assets/images/teams/india.png',
    'Australia': 'assets/images/teams/australia.png',
    'England': 'assets/images/teams/england.png',
    'CSK': 'assets/images/teams/csk.png',
    'MI': 'assets/images/teams/mi.png',
    'RCB': 'assets/images/teams/rcb.png',
    'KKR': 'assets/images/teams/kkr.png',
    'DC': 'assets/images/teams/dc.png',
    'RR': 'assets/images/teams/rr.png',
    'SRH': 'assets/images/teams/srh.png',
    'PBKS': 'assets/images/teams/pbks.png',
  };

  /// Get local team logo asset path, returns null if not found
  static String? getTeamLogoAsset(String teamName) {
    return teamLogoAssets[teamName];
  }
}
