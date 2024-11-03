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
        theHeight: 160.0, // Ajusta la altura según sea necesario
        theChild: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.access_alarms, // Ícono de reloj con manecillas
                    color: Color(0xFFffffff),
                    size: 32,
                  ),
                  const SizedBox(width: 12), // Espacio entre icono y texto
                  Text(
                    _currentTime,
                    style: const TextStyle(
                      fontFamily: 'geometria',
                      color: Color(0xFFffffff),
                      fontSize: 40, // Tamaño grande
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2), // Espacio entre hora y fecha
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Color(0xFFffffff),
                    size: 24,
                  ),
                  const SizedBox(width: 12), // Espacio entre icono y texto
                  Text(
                    _currentDate,
                    style: const TextStyle(
                      fontFamily: 'geometria',
                      color: Color(0xFFffffff),
                      fontSize: 18, // Tamaño más pequeño para la fecha
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
