// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:share_plus/share_plus.dart';
//
// import '../../../../core/constants/app_constants.dart';
// import '../../../../domain/entities/received_request.dart';
// import '../../../../domain/entities/sent_request.dart';
// import '../../../../injection_container.dart';
// import '../../../bloc/alarm_request/alarm_request_bloc.dart';
// import '../../../bloc/alarm_request/alarm_request_event.dart';
// import '../../../bloc/alarm_request/alarm_request_state.dart';
// import '../../../widgets/common/custom_app_bar.dart';
// import '../../../widgets/common/error_widget.dart';
// import '../../../widgets/common/loading_widget.dart';
// import '../../../widgets/request/request_item_widget.dart';
// import '../../../widgets/request/share_link_widget.dart';
//
// class RequestsPage extends StatefulWidget {
//   const RequestsPage({Key? key}) : super(key: key);
//
//   @override
//   State<RequestsPage> createState() => _RequestsPageState();
// }
//
// class _RequestsPageState extends State<RequestsPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late AlarmRequestBloc _alarmRequestBloc;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _alarmRequestBloc = sl<AlarmRequestBloc>();
//     _loadRequests();
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     _alarmRequestBloc.close();
//     super.dispose();
//   }
//
//   void _loadRequests() {
//     _alarmRequestBloc.add(const GetSentRequestsRequested());
//     _alarmRequestBloc.add(const GetReceivedRequestsRequested());
//   }
//
//   void _onRefresh() {
//     _loadRequests();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: _alarmRequestBloc,
//       child: Scaffold(
//         backgroundColor: AppConstants.backgroundColor,
//         appBar: CustomAppBar(
//           title: 'Requests',
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.share, color: Colors.white),
//               onPressed: _showShareDialog,
//             ),
//           ],
//         ),
//         body: Column(
//           children: [
//             _buildTabBar(),
//             Expanded(
//               child: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _buildReceivedRequestsTab(),
//                   _buildSentRequestsTab(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: _showShareDialog,
//           backgroundColor: AppConstants.primaryColor,
//           child: const Icon(Icons.add, color: Colors.white),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTabBar() {
//     return Container(
//       color: AppConstants.backgroundColor,
//       child: TabBar(
//         controller: _tabController,
//         labelColor: AppConstants.primaryColor,
//         unselectedLabelColor: Colors.grey,
//         indicatorColor: AppConstants.primaryColor,
//         indicatorWeight: 3,
//         tabs: const [
//           Tab(
//             text: 'Received',
//             icon: Icon(Icons.inbox),
//           ),
//           Tab(
//             text: 'Sent',
//             icon: Icon(Icons.send),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildReceivedRequestsTab() {
//     return BlocBuilder<AlarmRequestBloc, AlarmRequestState>(
//       builder: (context, state) {
//         if (state is AlarmRequestLoading) {
//           return const LoadingWidget();
//         }
//
//         if (state is AlarmRequestError) {
//           return CustomErrorWidget(
//             message: state.message,
//             onRetry: _onRefresh,
//           );
//         }
//
//         if (state is AlarmRequestLoaded) {
//           return _buildReceivedRequestsList(state.receivedRequests);
//         }
//
//         return const SizedBox.shrink();
//       },
//     );
//   }
//
//   Widget _buildSentRequestsTab() {
//     return BlocBuilder<AlarmRequestBloc, AlarmRequestState>(
//       builder: (context, state) {
//         if (state is AlarmRequestLoading) {
//           return const LoadingWidget();
//         }
//
//         if (state is AlarmRequestError) {
//           return CustomErrorWidget(
//             message: state.message,
//             onRetry: _onRefresh,
//           );
//         }
//
//         if (state is AlarmRequestLoaded) {
//           return _buildSentRequestsList(state.sentRequests);
//         }
//
//         return const SizedBox.shrink();
//       },
//     );
//   }
//
//   Widget _buildReceivedRequestsList(List<ReceivedRequest> requests) {
//     if (requests.isEmpty) {
//       return _buildEmptyState(
//         icon: Icons.inbox_outlined,
//         title: 'No Received Requests',
//         subtitle:
//             'When someone sends you an alarm request, it will appear here.',
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: () async => _onRefresh(),
//       color: AppConstants.primaryColor,
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: requests.length,
//         itemBuilder: (context, index) {
//           final request = requests[index];
//           return RequestItemWidget(
//             key: ValueKey(request.id),
//             request: request,
//             onAccept: () => _acceptRequest(request),
//             onReject: () => _rejectRequest(request),
//             onRecord: () => _recordAlarm(request),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildSentRequestsList(List<SentRequest> requests) {
//     if (requests.isEmpty) {
//       return _buildEmptyState(
//         icon: Icons.send_outlined,
//         title: 'No Sent Requests',
//         subtitle: 'Share your link with friends to request custom alarms.',
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: () async => _onRefresh(),
//       color: AppConstants.primaryColor,
//       child: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: requests.length,
//         itemBuilder: (context, index) {
//           final request = requests[index];
//           return RequestItemWidget(
//             key: ValueKey(request.id),
//             request: request,
//             onDelete: () => _deleteRequest(request),
//             onEdit: () => _editRequest(request),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildEmptyState({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//   }) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               icon,
//               size: 80,
//               color: Colors.grey[400],
//             ),
//             const SizedBox(height: 24),
//             Text(
//               title,
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.bold,
//                   ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               subtitle,
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Colors.grey[500],
//                   ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 32),
//             if (icon == Icons.send_outlined)
//               ElevatedButton.icon(
//                 onPressed: _showShareDialog,
//                 icon: const Icon(Icons.share),
//                 label: const Text('Share Request Link'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppConstants.primaryColor,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 24,
//                     vertical: 12,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showShareDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => ShareLinkWidget(
//         onShare: _shareRequestLink,
//       ),
//     );
//   }
//
//   void _shareRequestLink(String message) {
//     final link = 'https://famz.app/request/user123'; // Generate actual link
//     final shareText =
//         '$message\n\nUse this link to record an alarm for me:\n$link';
//
//     Share.share(
//       shareText,
//       subject: 'Famz Alarm Request',
//     );
//
//     // Create alarm request
//     _alarmRequestBloc.add(CreateAlarmRequestRequested(
//       message: message,
//       link: link,
//     ));
//   }
//
//   void _acceptRequest(ReceivedRequest request) {
//     _alarmRequestBloc.add(AcceptRequestRequested(requestId: request.id));
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Request from ${request.fromUser.username} accepted'),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }
//
//   void _rejectRequest(ReceivedRequest request) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Reject Request'),
//         content: Text(
//             'Are you sure you want to reject the request from ${request.fromUser.username}?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _alarmRequestBloc
//                   .add(RejectRequestRequested(requestId: request.id));
//
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text(
//                       'Request from ${request.fromUser.username} rejected'),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             },
//             child: const Text('Reject', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _recordAlarm(ReceivedRequest request) {
//     Navigator.pushNamed(
//       context,
//       '/record-alarm',
//       arguments: request,
//     );
//   }
//
//   void _deleteRequest(SentRequest request) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Request'),
//         content: const Text('Are you sure you want to delete this request?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _alarmRequestBloc
//                   .add(DeleteAlarmRequestRequested(requestId: request.id));
//
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Request deleted successfully'),
//                   backgroundColor: Colors.red,
//                 ),
//               );
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _editRequest(SentRequest request) {
//     Navigator.pushNamed(
//       context,
//       '/edit-request',
//       arguments: request,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../bloc/request/request_bloc.dart';
import '../../../bloc/request/request_event.dart';
import '../../../bloc/request/request_state.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/request/request_item_widget.dart';

class RequestsPage extends StatefulWidget {
  const RequestsPage({Key? key}) : super(key: key);

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
    context.read<RequestBloc>().add(GetReceivedRequestsRequested());
    context.read<RequestBloc>().add(GetSentRequestsRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Requests'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              _shareRequestLink();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Received'),
            Tab(text: 'Sent'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReceivedRequestsTab(),
          _buildSentRequestsTab(),
        ],
      ),
    );
  }

  Widget _buildReceivedRequestsTab() {
    return BlocBuilder<RequestBloc, RequestState>(
      builder: (context, state) {
        if (state is RequestLoading) {
          return const LoadingWidget();
        } else if (state is ReceivedRequestsLoaded) {
          if (state.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No received requests',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Share Your Link',
                    onPressed: _shareRequestLink,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<RequestBloc>().add(GetReceivedRequestsRequested());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.requests.length,
              itemBuilder: (context, index) {
                final request = state.requests[index];
                return RequestItemWidget(
                  request: request,
                  isReceived: true,
                  onAccept: () {
                    context.read<RequestBloc>().add(
                          AcceptRequestRequested(requestId: request.id),
                        );
                  },
                  onReject: () {
                    context.read<RequestBloc>().add(
                          RejectRequestRequested(requestId: request.id),
                        );
                  },
                  onRecord: () {
                    Navigator.pushNamed(
                      context,
                      '/record-alarm',
                      arguments: request,
                    );
                  },
                );
              },
            ),
          );
        } else if (state is RequestError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Retry',
                  onPressed: () {
                    context
                        .read<RequestBloc>()
                        .add(GetReceivedRequestsRequested());
                  },
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSentRequestsTab() {
    return BlocBuilder<RequestBloc, RequestState>(
      builder: (context, state) {
        if (state is RequestLoading) {
          return const LoadingWidget();
        } else if (state is SentRequestsLoaded) {
          if (state.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.send,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No sent requests',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<RequestBloc>().add(GetSentRequestsRequested());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.requests.length,
              itemBuilder: (context, index) {
                final request = state.requests[index];
                return RequestItemWidget(
                  request: request,
                  isReceived: false,
                  // onDelete: () {
                  onReject: () {
                    _showDeleteRequestDialog(context, request.id);
                  },
                  onAccept: () {},
                  onRecord: () {},
                );
              },
            ),
          );
        } else if (state is RequestError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Retry',
                  onPressed: () {
                    context.read<RequestBloc>().add(GetSentRequestsRequested());
                  },
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _shareRequestLink() {
    // TODO: Get actual user ID and generate proper link
    const userId = 'user123';
    const link = 'https://famz.app/request/$userId';

    Share.share(
      'Hey! I\'d like you to record an alarm for me. Click this link to get started: $link',
      subject: 'Famz Alarm Request',
    );
  }

  void _showDeleteRequestDialog(BuildContext context, int requestId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Request'),
          content: const Text('Are you sure you want to delete this request?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<RequestBloc>().add(
                      DeleteRequestRequested(requestId: requestId),
                    );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
