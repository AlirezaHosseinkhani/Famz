import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../routes/route_names.dart';
import '../../widgets/common/custom_button.dart';

class NotificationPermissionPage extends StatefulWidget {
  const NotificationPermissionPage({Key? key}) : super(key: key);

  @override
  State<NotificationPermissionPage> createState() =>
      _NotificationPermissionPageState();
}

class _NotificationPermissionPageState
    extends State<NotificationPermissionPage> {
  bool _isLoading = false;

  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final status = await Permission.notification.request();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteNames.main,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to request permission'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _skipPermission() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      RouteNames.main,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                        Icons.notifications_active,
                        size: 120,
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Enable Notifications',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Get notified when someone shares an alarm with you or responds to your requests',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color:
                            theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    _buildBenefitItem(
                      context,
                      Icons.schedule,
                      'Never miss your alarms',
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitItem(
                      context,
                      Icons.group,
                      'Get notified of new requests',
                    ),
                    const SizedBox(height: 16),
                    _buildBenefitItem(
                      context,
                      Icons.volume_up,
                      'Receive recording updates',
                    ),
                  ],
                ),
              ),
              CustomButton(
                text: 'Allow Notifications',
                onPressed: _requestPermission,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _skipPermission,
                child: Text(
                  'Skip for now',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          color: theme.primaryColor,
          size: 24,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
