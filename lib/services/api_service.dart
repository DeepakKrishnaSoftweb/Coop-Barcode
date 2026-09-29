import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../models/product_details_model.dart';
import '../utils/api_path.dart';
import '../utils/app_constants.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 15);

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

  // static Future<bool> login() async {
  //   try {
  //     final url = Uri.parse(ApiPath.baseUrl + ApiPath.sessionLogin);
  //     final response = await http
  //         .post(
  //           url,
  //           headers: const {'Content-Type': 'application/json'},
  //           body: jsonEncode(PrefConst.payload()),
  //         )
  //         .timeout(_timeout);
  //
  //     if (response.statusCode < 200 || response.statusCode >= 300) {
  //       return false;
  //     }
  //
  //     final rawCookie = response.headers['set-cookie'];
  //     if (rawCookie == null) return false;
  //
  //     final sessionId = _extractSessionId(rawCookie);
  //     if (sessionId == null || sessionId.isEmpty) return false;
  //
  //     await kAppStorage.setString(PrefConst.sessionId, sessionId);
  //     return true;
  //   } on TimeoutException {
  //     log('Login timeout');
  //     return false;
  //   } catch (e) {
  //     log('Login exception: $e');
  //     return false;
  //   }
  // }

  // static Future<void> ensureSession() async {
  //   final sessionId = kAppStorage.getString(PrefConst.sessionId);
  //   if (sessionId != null && sessionId.isNotEmpty) return true;
  //   return login();
  // }

  static String? _extractSessionId(String rawCookie) {
    final cookies = rawCookie.split(';');

    for (var cookie in cookies) {
      if (cookie.trim().startsWith("session_id=")) {
        return cookie.split('=').last;
      }
    }
    return null;
  }

  static Future<ProductDetails?> getProductByBarcode(
    String barcode, {
    bool retryOnSessionFailure = true,
  }) async {
    final cleanBarcode = barcode.trim();
    if (cleanBarcode.isEmpty) return null;

    try {
      //if (!await ensureSession()) return null;

      final safeBarcode = cleanBarcode.replaceAll("'", "\\'");
      final Uri url = Uri.parse(ApiPath.baseUrl + ApiPath.product).replace(
        queryParameters: {
          'by_AJR': '1',
          'domain': "[('barcode','=', '$safeBarcode')]",
        },
      );

      print("URL : $url");
      print("Session Id : ${kAppStorage.getString(PrefConst.sessionId)}");

      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Cookie':
                  'session_id=${kAppStorage.getString(PrefConst.sessionId)}',
            },
          )
          .timeout(_timeout);

      print("Response : ${response.body}");

      if ((response.statusCode == 401 || response.statusCode == 403) &&
          retryOnSessionFailure) {
        await kAppStorage.remove(PrefConst.sessionId);
        final loggedIn = await login();
        //if (!loggedIn) return null;
        return getProductByBarcode(cleanBarcode, retryOnSessionFailure: false);
      }

      if (response.statusCode != 200) {
        log('Product lookup HTTP ${response.statusCode}');
        return null;
      }

      final dynamic jsonData = jsonDecode(response.body);
      if (jsonData is! Map<String, dynamic>) return null;
      return ProductDetails.fromJson(jsonData);
    } on TimeoutException {
      log('Product lookup timeout');
      return null;
    } catch (e) {
      log('Product lookup exception: $e');
      return null;
    }
  }
}
