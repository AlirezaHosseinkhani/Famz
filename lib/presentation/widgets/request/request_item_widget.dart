import 'package:flutter/material.dart';

class RequestItemWidget extends StatelessWidget {
  final dynamic
      request; // You should replace `dynamic` with your specific request model type
  final bool isReceived;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onRecord;

  const RequestItemWidget({
    Key? key,
    required this.request,
    required this.isReceived,
    required this.onAccept,
    required this.onReject,
    required this.onRecord,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request: ${request.toString()}',
              // Customize this according to your model
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            if (isReceived)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onReject,
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onAccept,
                    child: const Text('Accept'),
                  ),
                ],
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: onRecord,
                  icon: const Icon(Icons.mic),
                  label: const Text('Record'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
