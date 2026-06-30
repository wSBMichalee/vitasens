import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class SnackbarUtils {
  static void showError(BuildContext context, String message, {SnackBarBehavior behavior = SnackBarBehavior.fixed}) {
    HapticFeedback.vibrate();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: behavior,
        ),
      );
  }

  static void showSuccess(BuildContext context, String message, {SnackBarBehavior behavior = SnackBarBehavior.fixed}) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.primary,
          behavior: behavior,
        ),
      );
  }
}
