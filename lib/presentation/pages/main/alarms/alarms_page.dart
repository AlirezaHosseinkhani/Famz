import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/snackbar_utils.dart';
import '../../../bloc/alarm/alarm_bloc.dart';
import '../../../bloc/alarm/alarm_event.dart';
import '../../../bloc/alarm/alarm_state.dart';
import '../../../routes/route_names.dart';
import '../../../widgets/alarm/alarm_item_widget.dart';
import '../../../widgets/common/custom_snackbar.dart';
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
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildHeader(),
            Expanded(
              child: BlocConsumer<AlarmBloc, AlarmState>(
                listener: (context, state) {
                  if (state is AlarmError) {
                    SnackbarUtils.showOverlaySnackbar(
                      context,
                      state.message,
                      SnackbarType.error,
                    );
                  } else if (state is AlarmCreated) {
                    SnackbarUtils.showOverlaySnackbar(
                      context,
                      'Alarm created successfully',
                      SnackbarType.success,
                    );
                  } else if (state is AlarmDeleted) {
                    SnackbarUtils.showOverlaySnackbar(
                      context,
                      'Alarm deleted successfully',
                      SnackbarType.success,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  height: 50,
                ),
                //     Text(
                //   'famz',
                //   style: TextStyle(
                //     color: Colors.black,
                //     fontSize: 16,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
              ),
            ],
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
        return AlarmItemWidget(
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
        );
      },
    );
  }

  Widget _buildAddAlarmButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ElevatedButton(
          onPressed: () async {
            final result =
                await Navigator.pushNamed(context, RouteNames.setAlarm);
            if (result == true) {
              context.read<AlarmBloc>().add(LoadAlarmsEvent());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[800],
            foregroundColor: Colors.white70,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: Colors.white70, size: 18),
              SizedBox(width: 8),
              Text(
                'Add Alarm',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
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
