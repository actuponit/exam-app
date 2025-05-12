import 'package:flutter/material.dart';

class AppSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.info,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _getIcon(type),
            color: Colors.white,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: _getBackgroundColor(type),
      duration: duration,
      action: actionLabel != null && onActionPressed != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onActionPressed,
            )
          : null,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 6,
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Color _getBackgroundColor(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Colors.green[700]!;
      case SnackBarType.error:
        return Colors.red[700]!;
      case SnackBarType.warning:
        return Colors.orange[700]!;
      case SnackBarType.info:
        return Colors.blue[700]!;
    }
  }

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_outline;
      case SnackBarType.error:
        return Icons.error_outline;
      case SnackBarType.warning:
        return Icons.warning_amber_rounded;
      case SnackBarType.info:
        return Icons.info_outline;
    }
  }

  static void success({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.success,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  static void error({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.error,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  static void warning({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.warning,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  static void info({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      type: SnackBarType.info,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }
}

enum SnackBarType {
  success,
  error,
  warning,
  info,
}
