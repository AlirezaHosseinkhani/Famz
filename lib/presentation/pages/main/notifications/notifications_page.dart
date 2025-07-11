// import 'package:famz/presentation/bloc/notification/notification_bloc.dart';
// import 'package:famz/presentation/widgets/common/custom_app_bar.dart';
// import 'package:famz/presentation/widgets/common/error_widget.dart';
// import 'package:famz/presentation/widgets/common/loading_widget.dart';
// import 'package:famz/presentation/widgets/notification/notification_item_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// class NotificationsPage extends StatelessWidget {
//   const NotificationsPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) =>
//           context.read<NotificationBloc>()..add(GetNotificationsRequested()),
//       child: const NotificationsView(),
//     );
//   }
// }
//
// class NotificationsView extends StatelessWidget {
//   const NotificationsView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: CustomAppBar(
//         title: 'Notifications',
//         titleColor: Colors.white,
//         backgroundColor: Colors.black,
//         showBackButton: false,
//         actions: [
//           BlocBuilder<NotificationBloc, NotificationState>(
//             builder: (context, state) {
//               if (state is NotificationLoaded &&
//                   state.notifications.any((n) => !n.isRead)) {
//                 return TextButton(
//                   onPressed: () {
//                     context.read<NotificationBloc>().add(
//                           MarkAllAsReadRequested(),
//                         );
//                   },
//                   child: const Text(
//                     'Mark all Read',
//                     style: TextStyle(
//                       color: Color(0xFFFF6B35),
//                       fontSize: 14,
//                     ),
//                   ),
//                 );
//               }
//               return const SizedBox.shrink();
//             },
//           ),
//         ],
//       ),
//       body: BlocBuilder<NotificationBloc, NotificationState>(
//         builder: (context, state) {
//           if (state is NotificationLoading) {
//             return const LoadingWidget();
//           }
//
//           if (state is NotificationError) {
//             return CustomErrorWidget(
//               message: state.message,
//               onRetry: () {
//                 context.read<NotificationBloc>().add(
//                       GetNotificationsRequested(),
//                     );
//               },
//             );
//           }
//
//           if (state is NotificationLoaded) {
//             if (state.notifications.isEmpty) {
//               return _buildEmptyState();
//             }
//
//             return RefreshIndicator(
//               onRefresh: () async {
//                 context.read<NotificationBloc>().add(
//                       GetNotificationsRequested(),
//                     );
//               },
//               child: ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: state.notifications.length,
//                 itemBuilder: (context, index) {
//                   final notification = state.notifications[index];
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: NotificationItemWidget(
//                       notification: notification,
//                       onTap: () {
//                         if (!notification.isRead) {
//                           context.read<NotificationBloc>().add(
//                                 MarkAsReadRequested(
//                                   notificationId: notification.id,
//                                 ),
//                               );
//                         }
//                         _handleNotificationTap(context, notification);
//                       },
//                     ),
//                   );
//                 },
//               ),
//             );
//           }
//
//           return _buildEmptyState();
//         },
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.notifications_none,
//             size: 80,
//             color: Colors.white.withOpacity(0.3),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No notifications',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.7),
//               fontSize: 18,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'You\'ll see notifications here when you receive them',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.5),
//               fontSize: 14,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _handleNotificationTap(BuildContext context, notification) {
//     // Handle navigation based on notification type
//     switch (notification.type) {
//       case NotificationType.alarmRequest:
//         // Navigate to requests page
//         break;
//       case NotificationType.recordingReceived:
//         // Navigate to alarms or recordings
//         break;
//       case NotificationType.alarmTriggered:
//         // Navigate to alarm details
//         break;
//       default:
//         break;
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/notification/notification_bloc.dart';
import '../../../bloc/notification/notification_state.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../widgets/notification/notification_item_widget.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    // context.read<NotificationBloc>().add(GetNotificationsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        automaticallyImplyLeading: false,
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationsLoaded &&
                  state.notifications.isNotEmpty) {
                final unreadCount = state.notifications
                    .where((notification) => !notification.isRead)
                    .length;

                if (unreadCount > 0) {
                  return TextButton(
                    onPressed: () {
                      // context
                      //     .read<NotificationBloc>()
                      //     .add(MarkAllAsReadRequested());
                    },
                    child: const Text('Mark all as read'),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const LoadingWidget();
          } else if (state is NotificationsLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications',
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
                // context
                //     .read<NotificationBloc>()
                //     .add(GetNotificationsRequested());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  return NotificationItemWidget(
                    notification: notification,
                    onTap: () {
                      if (!notification.isRead) {
                        // context.read<NotificationBloc>().add(
                        //       MarkAsReadRequested(
                        //           notificationId: notification.id),
                        //     );
                      }
                    },
                  );
                },
              ),
            );
          } else if (state is NotificationError) {
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
                  ElevatedButton(
                    onPressed: () {
                      // context
                      //     .read<NotificationBloc>()
                      //     .add(GetNotificationsRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
