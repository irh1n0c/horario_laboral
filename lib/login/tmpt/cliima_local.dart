import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'glass_button.dart';

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  _WeatherWidgetState createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  String _weatherInfo = 'Cargando...';
  String _city = '';

  @override
  void initState() {
    super.initState();
    _getLocationAndWeather();
  }

  Future<void> _getLocationAndWeather() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    await _fetchWeather(position.latitude, position.longitude);
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    const apiKey =
        '560eb9e705964544a9f151436242310'; // Reemplaza con tu API Key
    final url =
        'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$lat,$lon';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _city = data['location']['name'];
        _weatherInfo =
            '${data['current']['temp_c']} °C, ${data['current']['condition']['text']}';
      });
    } else {
      setState(() {
        _weatherInfo = 'Error al cargar el clima';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FrostedGlassBox(
        theWidth: MediaQuery.of(context).size.width * 1, // Ancho responsivo
        theHeight: 140.0, // Altura fija
        theChild: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _city,
                style: const TextStyle(
                  color: Color(0xFFbf4341),
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _weatherInfo,
                style: const TextStyle(
                  color: Color(0xFFbf4341),
                  fontSize: 25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
