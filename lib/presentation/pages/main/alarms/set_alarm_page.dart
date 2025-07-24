import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../../../../domain/entities/alarm.dart';
import '../../../bloc/alarm/alarm_bloc.dart';
import '../../../bloc/alarm/alarm_event.dart';
import '../../../widgets/common/custom_button.dart';

class SetAlarmPage extends StatefulWidget {
  final Alarm? alarm; // For editing existing alarm

  const SetAlarmPage({super.key, this.alarm});

  @override
  State<SetAlarmPage> createState() => _SetAlarmPageState();
}

class _SetAlarmPageState extends State<SetAlarmPage> {
  DateTime _selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
  String _videoPath = '';
  VideoPlayerController? _videoController;
  bool _isVideoLoading = false;

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

    // Initialize video controller if video exists
    if (_videoPath.isNotEmpty && File(_videoPath).existsSync()) {
      _videoController = VideoPlayerController.file(File(_videoPath))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      setState(() {
        _isVideoLoading = true;
      });

      // Copy the video to app's directory for persistence
      final directory = await getApplicationDocumentsDirectory();
      final fileName = video.name;
      final savedFile = File('${directory.path}/$fileName');

      await File(video.path).copy(savedFile.path);

      // Set up video controller
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(savedFile)
        ..initialize().then((_) {
          setState(() {
            _videoPath = savedFile.path;
            _isVideoLoading = false;
          });
        });
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    if (_isRecurring) {
      // For recurring alarms, only select time
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
      // For one-time alarms, select both date and time
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
    // Validate input
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
        videoPath: _videoPath,
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
            content: Text(
                'Error ${_isEditing ? 'updating' : 'creating'} alarm: $e')),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'When should the alarm go off?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDateTime(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[900],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TimeOfDay.fromDateTime(_selectedDateTime)
                              .format(context),
                          style: const TextStyle(
                              fontSize: 24, color: Colors.white),
                        ),
                        if (!_isRecurring)
                          Text(
                            DateFormat('EEE, MMM d, yyyy')
                                .format(_selectedDateTime),
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                      ],
                    ),
                    const Icon(Icons.access_time, color: Colors.white),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            // Recurring alarm section
            Row(
              children: [
                Switch(
                  value: _isRecurring,
                  onChanged: (value) {
                    setState(() {
                      _isRecurring = value;
                    });
                  },
                  activeColor: Colors.orange,
                ),
                const Text(
                  'Repeat weekly',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),

            // Show weekday selector if recurring is enabled
            if (_isRecurring) ...[
              const SizedBox(height: 16),
              const Text(
                'Select days:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: List.generate(7, (index) {
                  return FilterChip(
                    label: Text(_weekdays[index]),
                    selected: _selectedWeekdays[index],
                    onSelected: (selected) {
                      setState(() {
                        _selectedWeekdays[index] = selected;
                      });
                    },
                    selectedColor: Colors.orange,
                    backgroundColor: Colors.grey[800],
                    labelStyle: TextStyle(
                      color: _selectedWeekdays[index]
                          ? Colors.black
                          : Colors.white,
                    ),
                  );
                }),
              ),
            ],

            const SizedBox(height: 24),
            const Text(
              'Select a video to play when alarm goes off:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: CustomButton(
                text: 'Select Video',
                onPressed: _pickVideo,
                backgroundColor: Colors.grey[800]!,
                icon: const Icon(Icons.video_library),
              ),
            ),

            const SizedBox(height: 16),
            if (_isVideoLoading)
              const Center(child: CircularProgressIndicator())
            else if (_videoController != null &&
                _videoController!.value.isInitialized)
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_videoController!),
                    IconButton(
                      icon: Icon(
                        _videoController!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 50,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _videoController!.value.isPlaying
                              ? _videoController!.pause()
                              : _videoController!.play();
                        });
                      },
                    ),
                  ],
                ),
              )
            else if (_videoPath.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.videocam, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getFileName(_videoPath),
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: _isEditing ? 'Update Alarm' : 'Save Alarm',
                onPressed: _saveAlarm,
                backgroundColor: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFileName(String path) {
    if (path.isEmpty) return 'Default Alarm';
    return path.split('/').last;
  }
}
