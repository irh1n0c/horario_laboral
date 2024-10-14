import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapsTestPage extends StatefulWidget {
  const GoogleMapsTestPage({super.key});

  @override
  _GoogleMapsTestPageState createState() => _GoogleMapsTestPageState();
}

class _GoogleMapsTestPageState extends State<GoogleMapsTestPage> {
  GoogleMapController? _controller;
  static final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba de Google Maps'),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToCurrentLocation,
        label: const Text('Mi ubicación'),
        icon: const Icon(Icons.my_location),
      ),
    );
  }

  Future<void> _goToCurrentLocation() async {
    // Verificar permisos de ubicación
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permisos denegados
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permisos denegados permanentemente, manejarlo apropiadamente
      return;
    }

    // Obtener la posición actual
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final CameraPosition currentPosition = CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: 14,
    );

    await _controller
        ?.animateCamera(CameraUpdate.newCameraPosition(currentPosition));
  }
}
