import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/received_request.dart';
import '../../../../domain/entities/sent_request.dart';
import '../../../../injection_container.dart' as di;
import '../../../bloc/alarm_request/alarm_request_bloc.dart';
import '../../../bloc/alarm_request/alarm_request_event.dart';
import '../../../bloc/alarm_request/alarm_request_state.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/request/request_item_widget.dart';
import '../../../widgets/request/share_link_widget.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AlarmRequestBloc>()
        // ..add(GetReceivedRequestsEvent())
        // ..add(GetSentRequestsEvent()),
        ..add(LoadAllRequestsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Requests'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Received'),
              Tab(text: 'Sent'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<AlarmRequestBloc>().add(RefreshRequestsEvent());
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _showShareDialog(context),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            _ReceivedRequestsTab(),
            _SentRequestsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateRequestDialog(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ShareLinkWidget(
          onShare: (link) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Link shared: $link')),
            );
          },
        ),
      ),
    );
  }

  void _showCreateRequestDialog(BuildContext context) {
    final messageController = TextEditingController();
    final userIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: 'User ID',
                hintText: 'Enter user ID',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Enter request message',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final userId = int.tryParse(userIdController.text);
              if (userId != null && messageController.text.isNotEmpty) {
                context.read<AlarmRequestBloc>().add(
                      CreateAlarmRequestEvent(
                        toUserId: userId,
                        message: messageController.text,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _ReceivedRequestsTab extends StatelessWidget {
  const _ReceivedRequestsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmRequestBloc, AlarmRequestState>(
      builder: (context, state) {
        if (state is AlarmRequestLoading && !(state is AlarmRequestsLoaded)) {
          return const LoadingWidget();
        } else if (state is AlarmRequestError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: () {
              context.read<AlarmRequestBloc>().add(LoadAllRequestsEvent());
            },
          );
        }

        // Handle loaded state
        final receivedRequests = state is AlarmRequestsLoaded
            ? state.receivedRequests
            : <ReceivedRequest>[];

        if (receivedRequests.isEmpty) {
          return const Center(
            child: Text('No received requests'),
          );
        }

        return ListView.builder(
          itemCount: receivedRequests.length,
          itemBuilder: (context, index) {
            final request = receivedRequests[index];
            return RequestItemWidget(
              request: request,
              onAccept: () {
                context.read<AlarmRequestBloc>().add(
                      AcceptRequestEvent(requestId: request.id),
                    );
              },
              onReject: () {
                context.read<AlarmRequestBloc>().add(
                      RejectRequestEvent(requestId: request.id),
                    );
              },
              onRecord: () => _navigateToRecording(context, request),
            );
          },
        );
      },
    );
  }

  void _navigateToRecording(BuildContext context, ReceivedRequest request) {
    Navigator.pushNamed(
      context,
      '/record-alarm',
      arguments: request,
    );
  }
}

class _SentRequestsTab extends StatelessWidget {
  const _SentRequestsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmRequestBloc, AlarmRequestState>(
      builder: (context, state) {
        if (state is AlarmRequestLoading && !(state is AlarmRequestsLoaded)) {
          return const LoadingWidget();
        } else if (state is AlarmRequestError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: () {
              context.read<AlarmRequestBloc>().add(LoadAllRequestsEvent());
            },
          );
        }

        // Handle loaded state
        final sentRequests =
            state is AlarmRequestsLoaded ? state.sentRequests : <SentRequest>[];

        if (sentRequests.isEmpty) {
          return const Center(
            child: Text('No sent requests'),
          );
        }

        return ListView.builder(
          itemCount: sentRequests.length,
          itemBuilder: (context, index) {
            final request = sentRequests[index];
            return RequestItemWidget(
              request: request,
              onDelete: () {
                context.read<AlarmRequestBloc>().add(
                      DeleteAlarmRequestEvent(requestId: request.id),
                    );
              },
              onEdit: () => _showEditDialog(context, request),
            );
          },
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, SentRequest request) {
    final messageController = TextEditingController(text: request.message);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Request'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            labelText: 'Message',
            hintText: 'Enter request message',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (messageController.text.isNotEmpty) {
                context.read<AlarmRequestBloc>().add(
                      UpdateAlarmRequestEvent(
                        requestId: request.id,
                        message: messageController.text,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
