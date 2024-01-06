import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../widgets/countdown_style.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  Duration _countdownDuration = const Duration();
  late Timer _timer;
  late AnimationController _controller;
  late Animation<double> _animation;
  late bool _isCelebrating = false;
  late File _image;
  final picker = ImagePicker();

  //Image Picker function to get image from gallery
  Future<void> getImageFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (now.isBefore(_selectedDate)) {
        setState(() {
          _countdownDuration = _selectedDate.difference(now);
        });
      } else {
        timer.cancel();
        setState(() {
          _isCelebrating = true;
        });
        Future.delayed(const Duration(seconds: 5), () {
          setState(() {
            _isCelebrating = false;
          });
        });
      }
    });
  }

  String get _daysLeft {
    final days = _countdownDuration.inDays;
    return days == 1 ? '1 day' : '$days';
  }

  String get _hoursLeft {
    final hours = _countdownDuration.inHours.remainder(24);
    return hours == 1 ? '1 hr' : '$hours';
  }

  String get _minutesLeft {
    final minutes = _countdownDuration.inMinutes.remainder(60);
    return minutes == 1 ? '1 min' : '$minutes';
  }

  String get _secondsLeft {
    final seconds = _countdownDuration.inSeconds.remainder(60);
    return seconds == 1 ? '1 sec' : '$seconds';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _countdownDuration = _selectedDate.difference(DateTime.now());
        if (_timer.isActive) {
          _timer.cancel();
        }
        _startTimer();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[400],
      appBar: AppBar(
        title: const Text(
          'Countdown',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Countdown to ${DateFormat('MMMM dd, yyyy').format(_selectedDate)}',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                countDownStyle(
                  child: _buildCountdownItem(_daysLeft, 'Days'),
                ),
                const SizedBox(width: 16.0),
                countDownStyle(
                  child: _buildCountdownItem(_hoursLeft, 'Hr'),
                ),
                const SizedBox(width: 16.0),
                countDownStyle(
                  child: _buildCountdownItem(_minutesLeft, 'Min'),
                ),
                const SizedBox(width: 16.0),
                countDownStyle(
                  child: _buildCountdownItem(_secondsLeft, 'Sec'),
                )
              ],
            ),
            const SizedBox(height: 20.0),
            MaterialButton(
                color: Colors.purple,
                child: const Text("Pick image from gallery",
                    style: TextStyle(
                        color: Colors.white70, fontWeight: FontWeight.bold)),
                onPressed: () {
                  getImageFromGallery();
                }),
            const SizedBox(height: 40.0),
            if (_isCelebrating)
              ScaleTransition(
                scale: _animation,
                child: Column(
                  children: [
                    Text(
                      'Happy ${DateFormat('MMMM dd').format(_selectedDate)}!',
                      style: const TextStyle(fontSize: 40.0),
                    ),
                    const SizedBox(height: 16.0),
                    Image.network('https://i.gifer.com/XZ5V.gif', height: 300),
                  ],
                ),
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _selectDate(context),
        child: const Icon(Icons.calendar_today),
      ),
    );
  }

  Widget _buildCountdownItem(String value, String label) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 20.0),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 15.0),
          ),
        ],
      ),
    );
  }
}
