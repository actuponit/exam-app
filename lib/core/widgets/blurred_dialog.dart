import 'dart:ui';

import 'package:flutter/material.dart';

/// A reusable dialog with blurred background
/// 
/// This dialog can be used for confirmations, data input, or any other modal interaction
class BlurredDialog extends StatelessWidget {
  /// Title displayed at the top of the dialog
  final String title;
  
  /// Subtitle text displayed below the title
  final String subtitle;
  
  /// Main content widget of the dialog
  final Widget content;
  
  /// List of action widgets, typically buttons
  final List<Widget> actions;
  
  /// Blur intensity for the background
  final double blurIntensity;
  
  /// Padding around the dialog content
  final EdgeInsets contentPadding;
  
  /// Border radius for the dialog
  final double borderRadius;
  
  /// Whether the dialog can be dismissed by tapping outside
  final bool barrierDismissible;

  const BlurredDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.actions,
    this.blurIntensity = 5.0,
    this.contentPadding = const EdgeInsets.all(20),
    this.borderRadius = 20.0,
    this.barrierDismissible = false,
  });

  /// Show this dialog with a static convenience method
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget content,
    required List<Widget> actions,
    double blurIntensity = 5.0,
    EdgeInsets contentPadding = const EdgeInsets.all(20),
    double borderRadius = 20.0,
    bool barrierDismissible = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return BlurredDialog(
          title: title,
          subtitle: subtitle,
          content: content,
          actions: actions,
          blurIntensity: blurIntensity,
          contentPadding: contentPadding,
          borderRadius: borderRadius,
          barrierDismissible: barrierDismissible,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: blurIntensity,
        sigmaY: blurIntensity,
      ),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: _buildDialogContent(context),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Container(
      padding: contentPadding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 15),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          content,
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: actions.map((widget) {
              // Wrap each action with Expanded if there are multiple actions
              return actions.length > 1
                  ? Expanded(child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: widget,
                    ))
                  : widget;
            }).toList(),
          ),
        ],
      ),
    );
  }
} 