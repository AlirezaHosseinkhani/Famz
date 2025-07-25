import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/alarm/alarm_bloc.dart';
import '../../../bloc/alarm/alarm_event.dart';
import '../../../bloc/alarm/alarm_state.dart';
import '../../../routes/route_names.dart';
import '../../../widgets/alarm/alarm_item_widget.dart';
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
    context.read<AlarmBloc>().add(InitializeAlarmServiceEvent());
    context.read<AlarmBloc>().add(LoadAlarmsEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: BlocConsumer<AlarmBloc, AlarmState>(
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
                  }
                },
                builder: (context, state) {
                  if (state is AlarmLoading) {
                    return const LoadingWidget();
                  } else if (state is AlarmLoaded) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<AlarmBloc>().add(RefreshAlarmsEvent());
                      },
                      child: state.alarms.isEmpty
                          ? _buildEmptyState()
                          : _buildAlarmsList(state),
                    );
                  }
                  return const LoadingWidget();
                },
              ),
            ),
            _buildAddAlarmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'famz',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Today section
          const Text(
            'Today',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 100),
        Center(
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.alarm,
                  size: 60,
                  color: Colors.grey[600],
                ),
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
                'Tap + to create your first alarm',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlarmsList(AlarmLoaded state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: state.alarms.length,
      itemBuilder: (context, index) {
        final alarm = state.alarms[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: AlarmItemWidget(
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
              context.read<AlarmBloc>().add(
                    DeleteAlarmEvent(alarmId: alarm.id!),
                  );
            },
          ),
        );
      },
    );
  }

  Widget _buildAddAlarmButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final result =
                    await Navigator.pushNamed(context, RouteNames.setAlarm);
                if (result == true) {
                  context.read<AlarmBloc>().add(LoadAlarmsEvent());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.orange),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'Add Alarm',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String alarmId) {
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
