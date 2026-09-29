import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences kAppStorage;

class PrefConst {
  PrefConst._();

  static const String appName = 'Coop Product Lookup';
  static const String sessionId = 'sessionId';
  static const String preferredScanMode = 'preferredScanMode';
  static const String recentScans = 'recentScans';
  static const String noDataFound = 'No Product Found';

  static Map<String, dynamic> payload() {
    return <String, dynamic>{
      'jsonrpc': '2.0',
      'params': {
        'db': 'staging-apr17',
        'login': 'dev@eicoop',
        'password': 'Fy3V5wCwFiEf27n',
      },
    };
  }
}
