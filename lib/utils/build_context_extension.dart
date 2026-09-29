import 'package:flutter/material.dart';

import 'app_spacing.dart';

extension BuildContextExtension on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
  TextTheme get tt => Theme.of(this).textTheme;

  // Screen size utils

  double sw([double fraction = 1]) => MediaQuery.of(this).size.width * fraction;

  double sh([double fraction = 1]) =>
      MediaQuery.of(this).size.height * fraction;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showErrorSnackBar(
      String message, {
        Duration duration = const Duration(seconds: 1),
      }) {
    final messenger = ScaffoldMessenger.of(this);
    messenger.clearSnackBars();
    return messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.error,
        showCloseIcon: true,
        margin: EdgeInsets.all(AppSpacing.sm),
        duration: duration,
      ),
    );
  }
}