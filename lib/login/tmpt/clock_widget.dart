import 'package:flutter/material.dart';
import 'dart:async';
import 'glass_button.dart';

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
      child: FrostedGlassBox(
        theWidth: MediaQuery.of(context).size.width * 1, // Ancho responsivo
        theHeight: 140.0, // Ajusta la altura según sea necesario
        theChild: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentTime,
                style: const TextStyle(
                  color: Color(0xFFbf4341),
                  fontSize: 48, // Tamaño grande
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _currentDate,
                style: const TextStyle(
                  color: Color(0xFFbf4341),
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
