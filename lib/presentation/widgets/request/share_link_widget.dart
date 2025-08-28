import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/snackbar_utils.dart';
import '../common/custom_snackbar.dart';

class ShareLinkWidget extends StatelessWidget {
  final Function(String) onShare;

  const ShareLinkWidget({
    super.key,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final shareLink = _generateShareLink();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.share,
            size: 48,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          Text(
            'Share Your Request Link',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Share this link with others so they can send you alarm requests',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    shareLink,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace', color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => _copyToClipboard(context, shareLink),
                  icon: const Icon(Icons.copy),
                  color: Colors.black54,
                  tooltip: 'Copy to clipboard',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _copyToClipboard(context, shareLink),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareLink(shareLink),
                  icon: const Icon(
                    Icons.share,
                    color: Colors.white70,
                  ),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _generateShareLink() {
    // Generate a unique share link for the user
    // This would typically include the user's ID or a unique token
    return 'https://famz.app/request/username';
  }

  void _copyToClipboard(BuildContext context, String link) {
    Clipboard.setData(ClipboardData(text: link));
    SnackbarUtils.showOverlaySnackbar(
      context,
      'Link copied to clipboard',
      SnackbarType.info,
    );
    onShare(link);
  }

  void _shareLink(String link) {
    Share.share(
      'Hey! You can send me alarm requests using this link: $link',
      subject: 'Famz Alarm Request Link',
    );
    onShare(link);
  }
}
