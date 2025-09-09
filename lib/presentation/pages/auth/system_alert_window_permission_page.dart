import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/utils/snackbar_utils.dart';
import '../../routes/route_names.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_snackbar.dart';

class SystemAlertWindowPermissionPage extends StatefulWidget {
  final Map<String, dynamic>? arguments;

  const SystemAlertWindowPermissionPage({Key? key, this.arguments})
      : super(key: key);

  @override
  State<SystemAlertWindowPermissionPage> createState() =>
      _SystemAlertWindowPermissionPageState();
}

class _SystemAlertWindowPermissionPageState
    extends State<SystemAlertWindowPermissionPage> {
  Future<void> _requestPermission() async {
    // setState(() {
    //   _isLoading = true;
    // });

    try {
      final status = await Permission.systemAlertWindow.request();

      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          RouteNames.notificationPermission,
          arguments: widget.arguments,
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
    }
    // finally {
    //   if (mounted) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   }
    // }
  }

  void _skipPermission() {
    Navigator.of(context).pushReplacementNamed(
      RouteNames.notificationPermission,
      arguments: widget.arguments, // Pass along the arguments
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
                      Icons.open_in_new,
                      size: 120,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Allow App to Appear on Top?',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This allows the app to display over other apps for important alerts and quick access features',
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
                text: 'Allow Appear on Top',
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
}
