import 'package:barcode_scanner/services/api_service.dart';
import 'package:barcode_scanner/theme/theme_config.dart';
import 'package:barcode_scanner/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  kAppStorage = await SharedPreferences.getInstance();
  await ApiService.login();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: PrefConst.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeColor.lightThemeData,
      darkTheme: ThemeColor.lightThemeData,
      themeMode: ThemeMode.light,
      home: const HomePage(),
    );
  }
}
