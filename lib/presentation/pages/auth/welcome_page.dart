// lib/presentation/pages/auth/welcome_page.dart
import 'package:flutter/material.dart';

import '../../routes/route_names.dart';
import '../../widgets/common/custom_button.dart';

class WelcomePage extends StatelessWidget {
  final String name;
  final String emailOrPhone;

  const WelcomePage({
    Key? key,
    required this.name,
    required this.emailOrPhone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hand wave emoji
              Container(
                padding: const EdgeInsets.all(32),
                child: const Text(
                  '👋',
                  style: TextStyle(fontSize: 120),
                ),
              ),

              const SizedBox(height: 48),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Welcome, ',
                      style: TextStyle(color: Colors.black),
                    ),
                    TextSpan(
                      text: '$name!',
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Let\'s turn wake-ups into something you\'ll love.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 80),

              CustomButton(
                text: 'Continue',
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteNames.systemAlertWindowPermission,
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
