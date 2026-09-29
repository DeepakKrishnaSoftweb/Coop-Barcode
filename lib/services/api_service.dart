import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;

import '../models/product_details_model.dart';
import '../utils/api_path.dart';
import '../utils/app_constants.dart';

class ApiService {
  static Future<void> login() async {
    final url = Uri.parse(ApiPath.baseUrl + ApiPath.sessionLogin);
    log("API URL : $url");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(PrefConst.payload()),
    );
    final rawCookie = response.headers['set-cookie'];

    if (rawCookie != null) {
      final sessionId = _extractSessionId(rawCookie);
      log("SESSION ID: $sessionId");
      await kAppStorage.setString(PrefConst.sessionId, sessionId!);
    }
  }

  static String? _extractSessionId(String rawCookie) {
    final cookies = rawCookie.split(';');

    for (var cookie in cookies) {
      if (cookie.trim().startsWith("session_id=")) {
        return cookie.split('=').last;
      }
    }
    return null;
  }

  static Future<ProductDetails?> getProductByBarcode(String barcode) async {
    try {
      final Uri url = Uri.parse(ApiPath.baseUrl + ApiPath.product).replace(
        queryParameters: {
          "by_AJR": "1",
          "domain": "[('barcode','=', '$barcode')]",
        },
      );

      log("API URL : $url");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Cookie": "session_id=${kAppStorage.getString(PrefConst.sessionId)}",
        },
      );

      log("Response : ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ProductDetails.fromJson(jsonData);
      } else {
        log("Error: ${response.statusCode}");
      }
    } catch (e) {
      log("Exception: $e");
    }

    return null;
  }
}
