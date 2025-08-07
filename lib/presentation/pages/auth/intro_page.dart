import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/api_constants.dart';
import '../../../data/datasources/local/dev_config_service.dart';
import '../../routes/route_names.dart';
import '../../widgets/common/custom_button.dart';

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
    _showDevConfig = kDebugMode;
  }

  Future<void> _loadCurrentIp() async {
    final currentIp = await DevConfigService.getIpAddress();
    _ipController.text = currentIp;
  }

  Future<void> _saveIpAddress() async {
    if (_ipController.text.trim().isEmpty) {
      _showSnackBar('Please enter a valid IP address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await DevConfigService.setIpAddress(_ipController.text.trim());
      ApiConstants.refreshBaseUrl(); // Refresh the cached URL
      _showSnackBar('IP address saved successfully!');
    } catch (e) {
      _showSnackBar('Error saving IP address: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Dev Configuration Section (only in debug mode)
              if (_showDevConfig) _buildDevConfigSection(theme),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Container(
                    //   padding: const EdgeInsets.all(32),
                    //   decoration: BoxDecoration(
                    //     color: theme.primaryColor.withOpacity(0.1),
                    //     borderRadius: BorderRadius.circular(32),
                    //   ),
                    //   child: Icon(
                    //     Icons.people_alt_rounded,
                    //     size: 120,
                    //     color: theme.hintColor,
                    //   ),
                    // ),
                    const SizedBox(height: 48),
                    Text(
                      'Welcome to famz',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.hintColor,
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

  Widget _buildDevConfigSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
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
                  _showSnackBar('IP reset to default');
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
