import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/alarm/alarm_bloc.dart';
import '../../../bloc/alarm/alarm_event.dart';
import '../../../bloc/alarm/alarm_state.dart';
import '../../../routes/route_names.dart';
import '../../../widgets/alarm/alarm_item_widget.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/error_widget.dart';
import '../../../widgets/common/loading_widget.dart';

class AlarmsPage extends StatefulWidget {
  const AlarmsPage({super.key});

  @override
  State<AlarmsPage> createState() => _AlarmsPageState();
}

class _AlarmsPageState extends State<AlarmsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<AlarmBloc>().add(LoadAlarmsEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Alarms',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: BlocConsumer<AlarmBloc, AlarmState>(
        listener: (context, state) {
          if (state is AlarmError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AlarmCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Alarm created successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AlarmDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Alarm deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AlarmToggled) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Alarm ${state.alarm.isActive ? 'activated' : 'deactivated'}',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AlarmLoading) {
            return const LoadingWidget();
          } else if (state is AlarmError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<AlarmBloc>().add(LoadAlarmsEvent());
              },
            );
          } else if (state is AlarmLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<AlarmBloc>().add(RefreshAlarmsEvent());
              },
              child: Column(
                children: [
                  Expanded(
                    child: state.alarms.isEmpty
                        ? _buildEmptyState()
                        : _buildAlarmsList(state),
                  ),
                  _buildAddAlarmButton(),
                ],
              ),
            );
          }

          return const LoadingWidget();
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
            Icons.alarm_off,
            size: 100,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 24),
          Text(
            'No alarms set',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first alarm',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlarmsList(AlarmLoaded state) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (state.activeAlarms.isNotEmpty) ...[
          const Text(
            'Active Alarms',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...state.activeAlarms
              .map((alarm) => AlarmItemWidget(
                    alarm: alarm,
                    onToggle: (isActive) {
                      context.read<AlarmBloc>().add(
                            ToggleAlarmEvent(
                              alarmId: alarm.id!,
                              isActive: isActive,
                            ),
                          );
                    },
                    onEdit: () {
                      Navigator.pushNamed(
                        context,
                        RouteNames.setAlarm,
                        arguments: alarm,
                      );
                    },
                    onDelete: () {
                      _showDeleteDialog(alarm.id!);
                    },
                  ))
              .toList(),
          const SizedBox(height: 24),
        ],
        if (state.inactiveAlarms.isNotEmpty) ...[
          const Text(
            'Inactive Alarms',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...state.inactiveAlarms
              .map((alarm) => AlarmItemWidget(
                    alarm: alarm,
                    onToggle: (isActive) {
                      context.read<AlarmBloc>().add(
                            ToggleAlarmEvent(
                              alarmId: alarm.id!,
                              isActive: isActive,
                            ),
                          );
                    },
                    onEdit: () {
                      Navigator.pushNamed(
                        context,
                        RouteNames.setAlarm,
                        arguments: alarm,
                      );
                    },
                    onDelete: () {
                      _showDeleteDialog(alarm.id!);
                    },
                  ))
              .toList(),
        ],
      ],
    );
  }

  Widget _buildAddAlarmButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: CustomButton(
        text: 'Add Alarm',
        onPressed: () {
          Navigator.pushNamed(context, RouteNames.setAlarm);
        },
        backgroundColor: Colors.orange,
        icon: Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(int alarmId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Alarm',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this alarm?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AlarmBloc>().add(
                    DeleteAlarmEvent(alarmId: alarmId),
                  );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
