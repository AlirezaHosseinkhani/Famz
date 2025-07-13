import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/notification/notification_bloc.dart';
import '../../../bloc/notification/notification_event.dart';
import '../../../bloc/notification/notification_state.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/common/error_widget.dart';
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
    context.read<NotificationBloc>().add(GetNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(
        title: 'Notifications',
        backgroundColor: Colors.black,
        actions: [
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded &&
                  state.notifications.isNotEmpty) {
                return TextButton(
                  onPressed: () {
                    context.read<NotificationBloc>().add(MarkAllAsReadEvent());
                  },
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 14,
                    ),
                  ),
                );
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
          } else if (state is NotificationError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<NotificationBloc>().add(GetNotificationsEvent());
              },
            );
          } else if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState();
            }
            return _buildNotificationsList(state.notifications);
          } else if (state is NotificationMarkingAsRead) {
            return _buildNotificationsList(state.notifications);
          } else if (state is NotificationMarkingAllAsRead) {
            return _buildNotificationsList(state.notifications);
          }

          return _buildEmptyState();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you have notifications,\nthey\'ll appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(notifications) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationBloc>().add(RefreshNotificationsEvent());
      },
      backgroundColor: Colors.grey[900],
      color: Colors.orange,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationItemWidget(
            notification: notification,
            onTap: () {
              if (!notification.isRead) {
                context.read<NotificationBloc>().add(
                      MarkAsReadEvent(notification.id),
                    );
              }
            },
          );
        },
      ),
    );
  }
}
