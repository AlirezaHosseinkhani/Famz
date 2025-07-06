import 'package:flutter/material.dart';

import '../../routes/route_names.dart';
import '../../widgets/common/custom_button.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Icon(
                        Icons.people_alt_rounded,
                        size: 120,
                        color: theme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Welcome to famz',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create personalized alarms with voices and videos from your friends and family',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color:
                            theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    _buildFeatureItem(
                      context,
                      Icons.record_voice_over,
                      'Voice Alarms',
                      'Wake up to personal messages from loved ones',
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureItem(
                      context,
                      Icons.videocam,
                      'Video Alarms',
                      'Start your day with personalized video messages',
                    ),
                    const SizedBox(height: 24),
                    _buildFeatureItem(
                      context,
                      Icons.share,
                      'Easy Sharing',
                      'Share requests and receive custom recordings',
                    ),
                  ],
                ),
              ),
              CustomButton(
                text: 'Get Started',
                onPressed: () {
                  Navigator.of(context).pushNamed(RouteNames.phoneVerification);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
