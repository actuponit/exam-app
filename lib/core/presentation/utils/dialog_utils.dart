import 'package:exam_app/core/presentation/widgets/mode_selection_dialog.dart';
import 'package:flutter/material.dart';

class DialogUtils {
  static Future<void> showModeSelectionDialog(
    BuildContext context, {
    required String year,
    required String subjectId,
    String? chapterId,
    VoidCallback? onCancel,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => ModeSelectionDialog(
        year: year,
        subjectId: subjectId,
        chapterId: chapterId,
        onCancel: onCancel,
      ),
    );
  }
}
