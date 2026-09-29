import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences kAppStorage;

class PrefConst {
  PrefConst._();

  // App Name
  static const String appName = 'Barcode Scanner';

  /// shared pref key [sessionId]
  static const String sessionId = 'sessionId';

  ///No Data Found
  static const String noDataFound = 'No Data Found';

  static Map<String, dynamic> payload() {
    Map<String, dynamic> body = <String, dynamic>{
      "jsonrpc": "2.0",
      "params": {
        "db": "staging-apr17",
        "login": "dev@eicoop",
        "password": "Fy3V5wCwFiEf27n",
      },
    };
    return body;
  }
}
