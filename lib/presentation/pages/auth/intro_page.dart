// lib/presentation/pages/auth/intro_page.dart
import 'package:flutter/material.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/datasources/local/dev_config_service.dart';
import '../../routes/route_names.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_snackbar.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  final TextEditingController _ipController = TextEditingController();
  bool _showDevConfig = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentIp();
    // Only show dev config in debug mode
    // _showDevConfig = kDebugMode;
    _showDevConfig = false;
  }

  Future<void> _loadCurrentIp() async {
    final currentIp = await DevConfigService.getIpAddress();
    _ipController.text = currentIp;
  }

  Future<void> _saveIpAddress() async {
    if (_ipController.text.trim().isEmpty) {
      _showSnackBar('Please enter a valid IP address', SnackbarType.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await DevConfigService.setIpAddress(_ipController.text.trim());
      ApiConstants.refreshBaseUrl(); // Refresh the cached URL
      _showSnackBar('IP address saved successfully!', SnackbarType.success);
    } catch (e) {
      _showSnackBar('Error saving IP address: $e', SnackbarType.error);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, SnackbarType type) {
    SnackbarUtils.showOverlaySnackbar(
      context,
      message,
      type,
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Dev Configuration Section (only in debug mode)
              if (_showDevConfig)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                  child: _buildDevConfigSection(theme),
                ),

              // Main content - centered
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Alarm clock icon
                    SizedBox(
                      width: screenWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.alarm_on_outlined,
                            size: 80,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Main heading with emojis
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        children: [
                          const TextSpan(text: 'Wake up smiling '),
                          const TextSpan(text: '😊'),
                          const TextSpan(text: ',\nnot snoozing '),
                          const TextSpan(text: '😴'),
                          const TextSpan(text: '!'),
                        ],
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    // Subtitle with emojis
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'Replace boring alarms '),
                          const TextSpan(text: '😴'),
                          const TextSpan(
                              text:
                                  ' with fun videos\nand voice messages from your favorite\npeople '),
                          const TextSpan(text: '❤️'),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Continue button at bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Continue',
                    backgroundColor: Colors.white,
                    fontSize: 16,
                    textColor: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(RouteNames.emailPhoneInput);
                    },
                  ),
                ),
              ),

              // Home indicator
              Container(
                width: 134,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDevConfigSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.developer_mode, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Development Mode',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ipController,
            decoration: InputDecoration(
              labelText: 'Server IP Address',
              hintText: '192.168.1.100:8000',
              prefixIcon: const Icon(Icons.computer),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveIpAddress,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save, size: 16),
                  label: Text(_isLoading ? 'Saving...' : 'Save IP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () async {
                  await DevConfigService.clearIpAddress();
                  await _loadCurrentIp();
                  ApiConstants.refreshBaseUrl();
                  _showSnackBar('IP reset to default', SnackbarType.info);
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Reset to default',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
