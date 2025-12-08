import 'package:exam_app/core/presentation/widgets/mode_selection_dialog.dart';
import 'package:flutter/material.dart';

class DialogUtils {
  static Future<void> showModeSelectionDialog(
    BuildContext context, {
    required String year,
    required String subjectId,
    String? chapterId,
    String? region,
    VoidCallback? onCancel,
  }) {
    final theme = Theme.of(context);
    return showDialog(
      context: context,
      barrierColor: theme.colorScheme.background.withOpacity(0.7),
      builder: (context) => ModeSelectionDialog(
        year: year,
        subjectId: subjectId,
        chapterId: chapterId,
        region: region,
        onCancel: onCancel,
      ),
    );
  }

  static Future<void> showRationaleDialog(BuildContext context, {required VoidCallback onConfirm}) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Notification Permission'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('We need notification permission to show download progress in the background.'),
                Text('Please allow notifications.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }
}