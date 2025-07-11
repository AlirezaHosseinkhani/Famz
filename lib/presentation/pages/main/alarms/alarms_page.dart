import 'package:famz/core/constants/route_constants.dart';
import 'package:famz/presentation/bloc/alarm/alarm_bloc.dart';
import 'package:famz/presentation/bloc/alarm/alarm_event.dart';
import 'package:famz/presentation/bloc/alarm/alarm_state.dart';
import 'package:famz/presentation/widgets/alarm/alarm_item_widget.dart';
import 'package:famz/presentation/widgets/common/custom_app_bar.dart';
import 'package:famz/presentation/widgets/common/custom_button.dart';
import 'package:famz/presentation/widgets/common/error_widget.dart';
import 'package:famz/presentation/widgets/common/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AlarmsPage extends StatelessWidget {
  const AlarmsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<AlarmBloc>()..add(GetAlarmsEvent()),
      child: const AlarmsView(),
    );
  }
}

class AlarmsView extends StatelessWidget {
  const AlarmsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(
        title: 'famz',
        // titleColor: Color(0xFFFF6B35),
        backgroundColor: Colors.black,
        // showBackButton: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<AlarmBloc, AlarmState>(
              builder: (context, state) {
                if (state is AlarmLoading) {
                  return const LoadingWidget();
                }

                if (state is AlarmError) {
                  return CustomErrorWidget(
                    message: state.message,
                    onRetry: () {
                      // context.read<AlarmBloc>().add(GetAlarmsRequested());
                    },
                  );
                }

                if (state is AlarmsLoaded) {
                  if (state.alarms.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      // context.read<AlarmBloc>().add(GetAlarmsRequested());
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.alarms.length,
                      itemBuilder: (context, index) {
                        final alarm = state.alarms[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AlarmItemWidget(
                            alarm: alarm,
                            onToggle: (isActive) {
                              // context.read<AlarmBloc>().add(
                              //       ToggleAlarmRequested(
                              //         alarmId: alarm.id,
                              //         isActive: isActive,
                              //       ),
                              //     );
                            },
                            onEdit: () {
                              context.push(
                                '${RouteConstants.alarmDetails}/${alarm.id}',
                              );
                            },
                            onDelete: () {
                              _showDeleteDialog(context, alarm.id);
                            },
                          ),
                        );
                      },
                    ),
                  );
                }

                return _buildEmptyState(context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: 'Add Alarm',
              onPressed: () {
                context.push(RouteConstants.setAlarm);
              },
              backgroundColor: const Color(0xFFFF6B35),
              textColor: Colors.white,
              // icon: Icons.add,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.alarm_off,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No alarms set',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to create your first alarm',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int alarmId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text(
            'Delete Alarm',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this alarm?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // context.read<AlarmBloc>().add(
                //       DeleteAlarmRequested(alarmId: alarmId),
                //     );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
