import 'package:flutter/material.dart';

enum SnackbarType {
  success,
  error,
  warning,
  info,
}

class CustomSnackbar extends StatelessWidget {
  final String message;
  final SnackbarType type;
  final VoidCallback? onAction;
  final String? actionLabel;
  final Duration duration;

  const CustomSnackbar({
    Key? key,
    required this.message,
    this.type = SnackbarType.info,
    this.onAction,
    this.actionLabel,
    this.duration = const Duration(seconds: 4),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(theme),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(theme),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getIconBackgroundColor(theme),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIcon(),
              color: _getIconColor(theme),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Message
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getTitle(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Action button (if provided)
          if (onAction != null && actionLabel != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: _getActionColor(theme),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor(ThemeData theme) {
    switch (type) {
      case SnackbarType.success:
        return const Color(0xFF1B4D3E);
      case SnackbarType.error:
        return const Color(0xFF4D1B1B);
      case SnackbarType.warning:
        return const Color(0xFF4D3A1B);
      case SnackbarType.info:
        return const Color(0xFF1B2D4D);
    }
  }

  Color _getBorderColor(ThemeData theme) {
    switch (type) {
      case SnackbarType.success:
        return const Color(0xFF4CAF50);
      case SnackbarType.error:
        return theme.colorScheme.error;
      case SnackbarType.warning:
        return const Color(0xFFFF9800);
      case SnackbarType.info:
        return const Color(0xFF2196F3);
    }
  }

  Color _getIconBackgroundColor(ThemeData theme) {
    switch (type) {
      case SnackbarType.success:
        return const Color(0xFF4CAF50).withOpacity(0.2);
      case SnackbarType.error:
        return theme.colorScheme.error.withOpacity(0.2);
      case SnackbarType.warning:
        return const Color(0xFFFF9800).withOpacity(0.2);
      case SnackbarType.info:
        return const Color(0xFF2196F3).withOpacity(0.2);
    }
  }

  Color _getIconColor(ThemeData theme) {
    switch (type) {
      case SnackbarType.success:
        return const Color(0xFF4CAF50);
      case SnackbarType.error:
        return theme.colorScheme.error;
      case SnackbarType.warning:
        return const Color(0xFFFF9800);
      case SnackbarType.info:
        return const Color(0xFF2196F3);
    }
  }

  Color _getActionColor(ThemeData theme) {
    switch (type) {
      case SnackbarType.success:
        return const Color(0xFF4CAF50);
      case SnackbarType.error:
        return theme.colorScheme.error;
      case SnackbarType.warning:
        return const Color(0xFFFF9800);
      case SnackbarType.info:
        return const Color(0xFF2196F3);
    }
  }

  IconData _getIcon() {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle_outline;
      case SnackbarType.error:
        return Icons.error_outline;
      case SnackbarType.warning:
        return Icons.warning_amber_outlined;
      case SnackbarType.info:
        return Icons.info_outline;
    }
  }

  String _getTitle() {
    switch (type) {
      case SnackbarType.success:
        return 'Success';
      case SnackbarType.error:
        return 'Error';
      case SnackbarType.warning:
        return 'Warning';
      case SnackbarType.info:
        return 'Info';
    }
  }
}
