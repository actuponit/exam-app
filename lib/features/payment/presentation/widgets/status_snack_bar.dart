import 'package:flutter/material.dart';

class StatusSnackBar extends SnackBar {
  StatusSnackBar._({
    Key? key,
    required Widget content,
    SnackBarAction? action,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 4),
    SnackBarBehavior behavior = SnackBarBehavior.floating,
    double? width,
    ShapeBorder? shape,
  }) : super(
          key: key,
          content: content,
          action: action,
          backgroundColor: backgroundColor,
          duration: duration,
          behavior: behavior,
          width: width,
          shape: shape ?? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
        );

  /// Shows a success status message
  factory StatusSnackBar.success({
    required BuildContext context,
    required String message,
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    return StatusSnackBar._(
      backgroundColor: Colors.green[700],
      content: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
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
      action: actionLabel != null && onActionPressed != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onActionPressed,
            )
          : null,
    );
  }
  
  /// Shows an info/pending status message
  factory StatusSnackBar.info({
    required BuildContext context,
    required String message,
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    return StatusSnackBar._(
      backgroundColor: Colors.blue[700],
      content: Row(
        children: [
          const Icon(
            Icons.info_outline,
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
      action: actionLabel != null && onActionPressed != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onActionPressed,
            )
          : null,
    );
  }
  
  /// Shows an error/denied status message
  factory StatusSnackBar.error({
    required BuildContext context,
    required String message,
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    return StatusSnackBar._(
      backgroundColor: Colors.red[700],
      content: Row(
        children: [
          const Icon(
            Icons.error_outline,
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
      action: actionLabel != null && onActionPressed != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onActionPressed,
            )
          : null,
    );
  }
  
  /// Shows a warning status message
  factory StatusSnackBar.warning({
    required BuildContext context,
    required String message,
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    return StatusSnackBar._(
      backgroundColor: Colors.orange[700],
      content: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
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
      action: actionLabel != null && onActionPressed != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onActionPressed,
            )
          : null,
    );
  }
  
  static void showSnackBar(
    BuildContext context,
    SnackBar snackBar,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
} 