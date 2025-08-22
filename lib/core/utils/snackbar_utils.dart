import 'package:flutter/material.dart';

import '../../presentation/widgets/common/custom_snackbar.dart';

class SnackbarUtils {
  static void showSuccess(
    BuildContext context,
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    _showCustomSnackbar(
      context,
      message,
      SnackbarType.success,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 5),
  }) {
    _showCustomSnackbar(
      context,
      message,
      SnackbarType.error,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    _showCustomSnackbar(
      context,
      message,
      SnackbarType.warning,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    _showCustomSnackbar(
      context,
      message,
      SnackbarType.info,
      onAction: onAction,
      actionLabel: actionLabel,
      duration: duration,
    );
  }

  static void _showCustomSnackbar(
    BuildContext context,
    String message,
    SnackbarType type, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    // Clear any existing snackbar
    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBar = SnackBar(
      content: CustomSnackbar(
        message: message,
        type: type,
        onAction: onAction,
        actionLabel: actionLabel,
        duration: duration,
      ),
      duration: duration,
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Alternative overlay-based approach for more flexibility
  static void showOverlaySnackbar(
    BuildContext context,
    String message,
    SnackbarType type, {
    VoidCallback? onAction,
    String? actionLabel,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: CustomSnackbar(
            message: message,
            type: type,
            onAction: onAction != null
                ? () {
                    onAction();
                    overlayEntry.remove();
                  }
                : null,
            actionLabel: actionLabel,
            duration: duration,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto remove after duration
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
