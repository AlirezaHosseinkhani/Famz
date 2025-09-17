import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/snackbar_utils.dart';
import '../../../../data/datasources/local/auth_local_datasource.dart';
import '../../../../domain/entities/received_request.dart';
import '../../../../domain/entities/sent_request.dart';
import '../../../../injection_container.dart' as di;
import '../../../bloc/alarm_request/alarm_request_bloc.dart';
import '../../../bloc/alarm_request/alarm_request_event.dart';
import '../../../bloc/alarm_request/alarm_request_state.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/common/custom_snackbar.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/request/confirmation_dialog_widget.dart';
import '../../../widgets/request/create_request_dialog_widget.dart';
import '../../../widgets/request/request_item_widget.dart';
import '../../../widgets/request/share_link_widget.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({super.key});

  @override
  State<RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<RequestsPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late AlarmRequestBloc _alarmRequestBloc;
  late AuthLocalDataSource _authLocalDataSource;
  Timer? _debounceTimer;
  int _previousTabIndex = 0;
  String username = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _alarmRequestBloc = di.sl<AlarmRequestBloc>();
    _authLocalDataSource = di.sl<AuthLocalDataSource>();

    _tabController.addListener(_onTabChanged);

    // Add app lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Load initial data
    _alarmRequestBloc.add(LoadAllRequestsEvent());
    _loadUsername();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _alarmRequestBloc.close();
    super.dispose();
  }

  Future<void> _loadUsername() async {
    try {
      final fetchedUsername = await _authLocalDataSource.getUsername();
      if (mounted) {
        setState(() {
          username = fetchedUsername ?? "";
        });
      }
    } catch (e) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // App returned from background, refresh data
      _alarmRequestBloc.add(RefreshRequestsEvent());
    }
  }

  void _onTabChanged() {
    // Check if the tab actually changed
    if (_tabController.index != _previousTabIndex) {
      print('Tab changed from $_previousTabIndex to ${_tabController.index}');

      // Cancel previous timer
      _debounceTimer?.cancel();

      // Update previous tab index
      _previousTabIndex = _tabController.index;

      // Add debouncing to prevent excessive API calls
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        print('Refreshing data for tab ${_tabController.index}');
        // Refresh data when tab changes
        _alarmRequestBloc.add(RefreshRequestsEvent());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _alarmRequestBloc,
      child: BlocConsumer<AlarmRequestBloc, AlarmRequestState>(
        listener: (context, state) async {
          if (state is AlarmRequestOperationSuccess) {
            SnackbarUtils.showOverlaySnackbar(
              context,
              state.message,
              SnackbarType.success,
            );
          }
          // Show error messages
          else if (state is AlarmRequestError) {
            SnackbarUtils.showOverlaySnackbar(
              context,
              state.message,
              SnackbarType.error,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.black,
            appBar: CustomAppBar(
              title: 'Requests',
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    text: 'Received',
                    icon: Icon(Icons.inbox_outlined),
                  ),
                  Tab(
                    text: 'Sent',
                    icon: Icon(Icons.send_outlined),
                  ),
                ],
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: () {
                    context
                        .read<AlarmRequestBloc>()
                        .add(RefreshRequestsEvent());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.ios_share),
                  tooltip: 'Share Link',
                  onPressed: () => _showShareDialog(
                    context,
                  ),
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
              onPressed: () => createRequestDialog(context),
              tooltip: 'Create New Request',
              child: const Icon(Icons.add),
            ),
          );
        },
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
          username: username,
          onShare: (link) {
            Navigator.pop(context);
            SnackbarUtils.showOverlaySnackbar(
              context,
              'Link shared: $link',
              SnackbarType.info,
            );
          },
        ),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No received requests',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Requests from other users will appear here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 26),
                const Text(
                  'Let them wake you up...',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // TextButton(
                //   onPressed: () => createRequestDialog(context),
                //   style: TextButton.styleFrom(
                //     backgroundColor: Colors.orange,
                //     disabledBackgroundColor: Colors.black54,
                //   ),
                //   child: const Text(
                //     ' Request for an alarm media ',
                //     style: TextStyle(
                //       color: Colors.white,
                //       fontSize: 14,
                //       // fontWeight: FontWeight.w500,
                //     ),
                //   ),
                // ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                itemCount: receivedRequests.length + 1,
                // Add 1 for the extra item
                itemBuilder: (context, index) {
                  // Check if this is the last item (extra item)
                  if (index == receivedRequests.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
                      child: Column(
                        children: [
                          const Text(
                            'Let them wake you up...',
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          // TextButton(
                          //   onPressed: () => createRequestDialog(context),
                          //   style: TextButton.styleFrom(
                          //     backgroundColor: Colors.white24,
                          //     disabledBackgroundColor: Colors.black54,
                          //   ),
                          //   child: const Text(
                          //     ' Request for an alarm media ',
                          //     style: TextStyle(
                          //       color: Colors.white70,
                          //       fontSize: 14,
                          //       // fontWeight: FontWeight.w500,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    );
                  }

                  // Regular list items
                  final request = receivedRequests[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: RequestItemWidget(
                      request: request,
                      onAccept: () {
                        confirmationDialog(
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
                        confirmationDialog(
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.send_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No sent requests',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap the below button to create your first request',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 26),
                const Text(
                  'Let them wake you up...',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // TextButton(
                //   onPressed: () => createRequestDialog(context),
                //   style: TextButton.styleFrom(
                //     backgroundColor: Colors.orange,
                //     disabledBackgroundColor: Colors.black54,
                //   ),
                //   child: const Text(
                //     ' Request for an alarm media ',
                //     style: TextStyle(
                //       color: Colors.white,
                //       fontSize: 14,
                //       // fontWeight: FontWeight.w500,
                //     ),
                //   ),
                // ),
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
