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
  String _weatherInfoToday = 'Cargando...';
  String _weatherInfoYesterday = 'Cargando...';
  String _rainChanceToday = 'Cargando...';
  String _city = '';

  @override
  void initState() {
    super.initState();
    _getLocationAndWeather();
  }

  Future<void> _getLocationAndWeather() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );
    await _fetchWeather(position.latitude, position.longitude);
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    const apiKey =
        '560eb9e705964544a9f151436242310'; // Reemplaza con tu API Key
    final todayUrl =
        'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$lat,$lon';
    final forecastUrl =
        'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$lat,$lon&days=2';

    // Clima de hoy
    final todayResponse = await http.get(Uri.parse(todayUrl));
    if (todayResponse.statusCode == 200) {
      final todayData = jsonDecode(todayResponse.body);
      setState(() {
        _city = todayData['location']['name'];
        _weatherInfoToday =
            '${todayData['current']['temp_c']} °C, ${todayData['current']['condition']['text']}';
      });
    } else {
      setState(() {
        _weatherInfoToday = 'Error al cargar el clima de hoy';
      });
    }

    // Clima de ayer y probabilidad de lluvia de hoy
    final forecastResponse = await http.get(Uri.parse(forecastUrl));
    if (forecastResponse.statusCode == 200) {
      final forecastData = jsonDecode(forecastResponse.body);
      setState(() {
        _weatherInfoYesterday =
            '${forecastData['forecast']['forecastday'][0]['day']['avgtemp_c']} °C, ${forecastData['forecast']['forecastday'][0]['day']['condition']['text']}';
        _rainChanceToday =
            '${forecastData['forecast']['forecastday'][1]['day']['daily_chance_of_rain']}%';
      });
    } else {
      setState(() {
        _weatherInfoYesterday = 'Error al cargar el clima de ayer';
        _rainChanceToday = 'Error al cargar probabilidad de lluvia';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FrostedGlassBox(
        theWidth: MediaQuery.of(context).size.width,
        theHeight: 220.0,
        theChild: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _city,
                style: const TextStyle(
                  fontFamily: 'geometria',
                  color: Color(0xFFffffff),
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wb_sunny,
                    color: Colors.yellow,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.cloud,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Hoy: $_weatherInfoToday',
                    style: const TextStyle(
                      fontFamily: 'geometria',
                      color: Color(0xFFffffff),
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .center, // Centrar las columnas horizontalmente
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // Centrar el contenido en cada columna
                    children: [
                      const Text(
                        'Clima de ayer',
                        style: TextStyle(
                          fontFamily: 'geometria',
                          color: Color(0xFFffffff),
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        _weatherInfoYesterday,
                        style: const TextStyle(
                          fontFamily: 'geometria',
                          color: Color(0xFFFFEF10),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40), // Espacio entre las dos columnas
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Probabilidad de lluvia hoy',
                        style: TextStyle(
                          fontFamily: 'geometria',
                          color: Color(0xFFffffff),
                          fontSize: 15,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.water_drop, // Icono de lluvia
                            color: Colors.blue, // Color para el icono de lluvia
                            size: 18,
                          ),
                          const SizedBox(
                              width: 4), // Espacio entre el icono y el texto
                          Text(
                            _rainChanceToday,
                            style: const TextStyle(
                              fontFamily: 'geometria',
                              color: Color(0xFFffffff),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
