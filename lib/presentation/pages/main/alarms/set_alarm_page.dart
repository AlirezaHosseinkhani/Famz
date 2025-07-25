import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../domain/entities/alarm.dart';
import '../../../../domain/entities/alarm_recording.dart';
import '../../../bloc/alarm/alarm_bloc.dart';
import '../../../bloc/alarm/alarm_event.dart';
import '../../../bloc/alarm_recording/alarm_recording_bloc.dart';
import '../../../bloc/alarm_recording/alarm_recording_event.dart';
import '../../../bloc/alarm_recording/alarm_recording_state.dart';
import '../../../widgets/alarm/media_selector_widget.dart';
import '../../../widgets/common/custom_button.dart';

class SetAlarmPage extends StatefulWidget {
  final Alarm? alarm;

  const SetAlarmPage({super.key, this.alarm});

  @override
  State<SetAlarmPage> createState() => _SetAlarmPageState();
}

class _SetAlarmPageState extends State<SetAlarmPage> {
  DateTime _selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
  String _videoPath = '';
  AlarmRecording? _selectedRecording;

  bool _isRecurring = false;
  final List<bool> _selectedWeekdays = List.filled(7, false);

  final List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  bool get _isEditing => widget.alarm != null;

  @override
  void initState() {
    super.initState();
    context.read<AlarmRecordingBloc>().add(LoadRecordingsEvent());

    if (_isEditing) {
      _initializeWithExistingAlarm();
    }
  }

  void _initializeWithExistingAlarm() {
    final alarm = widget.alarm!;
    _selectedDateTime = alarm.scheduledTime;
    _videoPath = alarm.videoPath;
    _isRecurring = alarm.isRecurring;

    for (int i = 0; i < 7; i++) {
      _selectedWeekdays[i] = alarm.weekdays[i];
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    if (_isRecurring) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    } else {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDateTime,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );

      if (pickedDate != null) {
        final TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
        );

        if (pickedTime != null) {
          setState(() {
            _selectedDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );
          });
        }
      }
    }
  }

  Future<void> _saveAlarm() async {
    if (!_isRecurring && _selectedDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a future time')),
      );
      return;
    }

    if (_isRecurring && !_selectedWeekdays.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select at least one day of the week')),
      );
      return;
    }

    try {
      final alarm = Alarm(
        id: _isEditing ? widget.alarm!.id : const Uuid().v4(),
        scheduledTime: _selectedDateTime,
        videoPath: _selectedRecording?.localPath ?? _videoPath,
        isRecurring: _isRecurring,
        weekdays: _selectedWeekdays,
      );

      if (_isEditing) {
        context.read<AlarmBloc>().add(UpdateAlarmEvent(alarm: alarm));
      } else {
        context.read<AlarmBloc>().add(CreateAlarmEvent(alarm: alarm));
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Error ${_isEditing ? 'updating' : 'creating'} alarm: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          _isEditing ? 'Edit Alarm' : 'Add Alarm',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Selection
            _buildTimeSection(),
            const SizedBox(height: 32),

            // Repeat Section
            _buildRepeatSection(),
            const SizedBox(height: 32),

            // Media Selection
            _buildMediaSection(),
            const SizedBox(height: 40),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date and Time',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: () => _selectDateTime(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('h:mm a').format(_selectedDateTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!_isRecurring)
                        Text(
                          DateFormat('EEE, MMM d, yyyy')
                              .format(_selectedDateTime),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRepeatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Repeat',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Repeat alarm',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Switch(
                    value: _isRecurring,
                    onChanged: (value) {
                      setState(() {
                        _isRecurring = value;
                        if (!value) {
                          for (int i = 0; i < 7; i++) {
                            _selectedWeekdays[i] = false;
                          }
                        }
                      });
                    },
                    activeColor: Colors.orange,
                  ),
                ],
              ),
              if (_isRecurring) ...[
                const SizedBox(height: 16),
                const Divider(color: Colors.grey),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedWeekdays[index] = !_selectedWeekdays[index];
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedWeekdays[index]
                              ? Colors.orange
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _selectedWeekdays[index]
                                ? Colors.orange
                                : Colors.grey,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _weekdays[index][0],
                            style: TextStyle(
                              color: _selectedWeekdays[index]
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pick a media',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        BlocBuilder<AlarmRecordingBloc, AlarmRecordingState>(
          builder: (context, state) {
            if (state is AlarmRecordingLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              );
            } else if (state is AlarmRecordingLoaded) {
              return MediaSelectorWidget(
                recordings: state.recordings,
                selectedRecording: _selectedRecording,
                onRecordingSelected: (recording) {
                  setState(() {
                    _selectedRecording = recording;
                  });
                },
                onDownloadRequested: (recording) {
                  context.read<AlarmRecordingBloc>().add(
                        DownloadRecordingEvent(recording: recording),
                      );
                },
              );
            } else if (state is AlarmRecordingError) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[900]?.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Back',
            onPressed: () => Navigator.pop(context),
            backgroundColor: Colors.grey[800]!,
            textColor: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: _isEditing ? 'Update alarm' : 'Create alarm',
            onPressed: _saveAlarm,
            backgroundColor: Colors.orange,
            textColor: Colors.black,
          ),
        ),
      ],
    );
  }
}
