import 'package:flutter/material.dart';
import 'dart:async';
import 'package:horario_fismet/card_tmp.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  _ClockWidgetState createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  String _currentTime = '';
  String _currentDate = '';

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
          '${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';
      _currentDate =
          '${now.day.toString().padLeft(2, '0')} / ${now.month.toString().padLeft(2, '0')} / ${now.year}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CardBackground(
        backgroundColor: const Color(0xFF9d9e54),
        height: 140.0,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentTime,
                style: const TextStyle(
                  color: Color(0xFFffffff),
                  fontSize: 48, // Tamaño grande
                  fontWeight: FontWeight.bold,
                ),
              ),
              //const SizedBox(height: 1), // Espacio entre la hora y la fecha
              Text(
                _currentDate,
                style: const TextStyle(
                  color: Color(0xFFffffff),
                  fontSize: 24, // Tamaño más pequeño para la fecha
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
