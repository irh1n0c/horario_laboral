import 'package:flutter/material.dart';
import 'dart:async';
import 'package:horario_fismet/card_tmp.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  _ClockWidgetState createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CardBackground(
        backgroundColor: const Color.fromARGB(255, 32, 32, 32),
        height: 200.0,
        child: Center(
          child: Text(
            _currentTime,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48, // Tamaño grande
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
