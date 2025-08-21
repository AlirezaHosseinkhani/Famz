import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../routes/route_names.dart';
import 'custom_button.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final String? retryText;
  final IconData? icon;

  const CustomErrorWidget({
    Key? key,
    required this.message,
    this.title,
    this.onRetry,
    this.retryText,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: retryText ?? 'Try Again',
                onPressed: onRetry,
                width: 150,
                backgroundColor: Colors.transparent,
                fontSize: 16,
                textColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(height: 8),
              CustomButton(
                text: 'Logout',
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutEvent());
                  Navigator.of(context).pushReplacementNamed(RouteNames.intro);
                },
                width: 150,
                backgroundColor: Colors.white,
                fontSize: 16,
                textColor: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
