import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/utils/snackbar_utils.dart';
import '../../routes/route_names.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_snackbar.dart';

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
        SnackbarUtils.showOverlaySnackbar(
          context,
          "Failed to request permission",
          SnackbarType.warning,
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
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: 120,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Turn on Notifications?',
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
                  ],
                ),
              ),
              CustomButton(
                text: 'Allow Notifications',
                backgroundColor: Colors.white,
                fontSize: 16,
                textColor: Colors.black,
                borderRadius: BorderRadius.circular(12),
                onPressed: _requestPermission,
                // isLoading: _isLoading,
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Skip for now',
                backgroundColor: Colors.grey.shade900,
                fontSize: 16,
                textColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                onPressed: _skipPermission,
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
