import 'package:flutter/material.dart';
import 'package:horario_fismet/card_tmp.dart';

class WeatherCard extends StatelessWidget {
  final String location;
  final String temperature;
  final String condition;

  const WeatherCard({
    super.key,
    required this.location,
    required this.temperature,
    required this.condition,
  });

  @override
  Widget build(BuildContext context) {
    return CardBackground(
      backgroundColor: const Color.fromARGB(255, 208, 208, 211),
      height: 100.0, // Ajusta la altura según necesites
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location,
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            Text(
              '$temperature °C',
              style: const TextStyle(color: Colors.white, fontSize: 22),
            ),
            Text(
              condition,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
