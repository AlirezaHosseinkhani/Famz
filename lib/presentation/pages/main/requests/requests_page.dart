import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/entities/received_request.dart';
import '../../../../domain/entities/sent_request.dart';
import '../../../../injection_container.dart' as di;
import '../../../bloc/alarm_request/alarm_request_bloc.dart';
import '../../../bloc/alarm_request/alarm_request_event.dart';
import '../../../bloc/alarm_request/alarm_request_state.dart';
import '../../../widgets/common/custom_app_bar.dart';
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
  late AlarmRequestBloc _alarmRequestBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _alarmRequestBloc = di.sl<AlarmRequestBloc>();
    // Load initial data
    _alarmRequestBloc.add(LoadAllRequestsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _alarmRequestBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _alarmRequestBloc,
      child: BlocListener<AlarmRequestBloc, AlarmRequestState>(
        listener: (context, state) {
          // Show success messages
          if (state is AlarmRequestOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
          // Show error messages
          else if (state is AlarmRequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black54,
          appBar: CustomAppBar(
            title: 'Requests',
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  text: 'Received',
                  icon: Icon(Icons.inbox),
                ),
                Tab(
                  text: 'Sent',
                  icon: Icon(Icons.send),
                ),
              ],
            ),
            centerTitle: true,
            actions: [
              // IconButton(
              //   icon: const Icon(Icons.refresh),
              //   tooltip: 'Refresh',
              //   onPressed: () {
              //     context.read<AlarmRequestBloc>().add(RefreshRequestsEvent());
              //   },
              // ),
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'Share Link',
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
            tooltip: 'Create New Request',
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ShareLinkWidget(
          onShare: (link) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Link shared: $link'),
                backgroundColor: Colors.blue,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showCreateRequestDialog(BuildContext context) {
    final messageController = TextEditingController();
    final userIdController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Create New Request'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: userIdController,
                decoration: const InputDecoration(
                  labelText: 'User ID',
                  hintText: 'Enter user ID',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a user ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Enter request message',
                  prefixIcon: Icon(Icons.message),
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a message';
                  }
                  if (value.trim().length < 3) {
                    return 'Message must be at least 3 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final userId = int.parse(userIdController.text);
                context.read<AlarmRequestBloc>().add(
                      CreateAlarmRequestEvent(
                        toUserId: userId,
                        message: messageController.text.trim(),
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
        // Handle loading state
        if (state is AlarmRequestLoading && !state.preserveData) {
          return const LoadingWidget();
        }

        // Handle error state
        if (state is AlarmRequestError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: () {
              context.read<AlarmRequestBloc>().add(LoadAllRequestsEvent());
            },
          );
        }

        // Extract received requests from loaded state
        List<ReceivedRequest> receivedRequests = [];
        if (state is AlarmRequestsLoaded) {
          receivedRequests = state.receivedRequests;
        }

        // Handle empty state
        if (receivedRequests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No received requests',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Requests from other users will appear here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Build list with loading overlay
        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                context.read<AlarmRequestBloc>().add(RefreshRequestsEvent());
                // Wait for the refresh to complete
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                itemCount: receivedRequests.length,
                itemBuilder: (context, index) {
                  final request = receivedRequests[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: RequestItemWidget(
                      request: request,
                      onAccept: () {
                        _showConfirmationDialog(
                          context,
                          'Accept Request',
                          'Are you sure you want to accept this request from ${request.fromUser.username ?? 'Unknown User'}?',
                          () {
                            context.read<AlarmRequestBloc>().add(
                                  AcceptRequestEvent(requestId: request.id),
                                );
                          },
                          confirmButtonColor: Colors.green,
                        );
                      },
                      onReject: () {
                        _showConfirmationDialog(
                          context,
                          'Reject Request',
                          'Are you sure you want to reject this request from ${request.fromUser.username ?? 'Unknown User'}?',
                          () {
                            context.read<AlarmRequestBloc>().add(
                                  RejectRequestEvent(requestId: request.id),
                                );
                          },
                          confirmButtonColor: Colors.red,
                        );
                      },
                      onRecord: () => _navigateToRecording(context, request),
                    ),
                  );
                },
              ),
            ),
            // Show loading overlay during operations
            if (state is AlarmRequestLoading && state.preserveData)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Processing request...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm, {
    Color? confirmButtonColor,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmButtonColor,
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
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
        // Handle loading state
        if (state is AlarmRequestLoading && !state.preserveData) {
          return const LoadingWidget();
        }

        // Handle error state
        if (state is AlarmRequestError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: () {
              context.read<AlarmRequestBloc>().add(LoadAllRequestsEvent());
            },
          );
        }

        // Extract sent requests from loaded state
        List<SentRequest> sentRequests = [];
        if (state is AlarmRequestsLoaded) {
          sentRequests = state.sentRequests;
        }

        // Handle empty state
        if (sentRequests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.send_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No sent requests',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to create your first request',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Build list with loading overlay
        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                context.read<AlarmRequestBloc>().add(RefreshRequestsEvent());
                // Wait for the refresh to complete
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                itemCount: sentRequests.length,
                itemBuilder: (context, index) {
                  final request = sentRequests[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: RequestItemWidget(
                      request: request,
                      onDelete: () {
                        _showConfirmationDialog(
                          context,
                          'Delete Request',
                          'Are you sure you want to delete this request to ${request.toUser.username ?? 'Unknown User'}?',
                          () {
                            context.read<AlarmRequestBloc>().add(
                                  DeleteAlarmRequestEvent(
                                      requestId: request.id),
                                );
                          },
                          confirmButtonColor: Colors.red,
                        );
                      },
                      onEdit: () => _showEditDialog(context, request),
                    ),
                  );
                },
              ),
            ),
            // Show loading overlay during operations
            if (state is AlarmRequestLoading && state.preserveData)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Processing request...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm, {
    Color? confirmButtonColor,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmButtonColor,
            ),
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, SentRequest request) {
    final messageController = TextEditingController(text: request.message);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text('Edit Request'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: messageController,
            decoration: const InputDecoration(
              labelText: 'Message',
              hintText: 'Enter request message',
              prefixIcon: Icon(Icons.edit),
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a message';
              }
              if (value.trim().length < 3) {
                return 'Message must be at least 3 characters';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                context.read<AlarmRequestBloc>().add(
                      UpdateAlarmRequestEvent(
                        requestId: request.id,
                        message: messageController.text.trim(),
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
