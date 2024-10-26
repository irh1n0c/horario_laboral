import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoogleMapsTestPage extends StatefulWidget {
  @override
  _GoogleMapsTestPageState createState() => _GoogleMapsTestPageState();
}

class _GoogleMapsTestPageState extends State<GoogleMapsTestPage> {
  late GoogleMapController mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('El servicio de ubicación está deshabilitado.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Los permisos de ubicación están denegados.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Los permisos de ubicación están permanentemente denegados.');
    }

    Position position = await Geolocator.getCurrentPosition();

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];

    String street = place.street ?? 'No disponible';
    String city = place.locality ?? 'No disponible';
    String district = place.subLocality ?? 'No disponible';
    String country = place.country ?? 'No disponible';

    print('Dirección: $street, $city, $district, $country');

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: _currentPosition!,
          infoWindow: InfoWindow(title: 'Ubicación Actual: $street'),
        ),
      );

      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition!,
            zoom: 15.0,
          ),
        ),
      );
    });

    _guardarDireccionEnFirestore(street, city, district, country);
  }

  Future<void> _guardarDireccionEnFirestore(
      String street, String city, String district, String country) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String fecha =
          DateTime.now().toLocal().toIso8601String().substring(0, 10);
      DocumentReference diaRef = FirebaseFirestore.instance
          .collection('registros_tiempo')
          .doc(user.uid)
          .collection('dias')
          .doc(fecha);

      await diaRef.set({
        'direccion': '$street, $city, $district, $country',
      }, SetOptions(merge: true));
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_currentPosition != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition!,
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi ubicación Fismet',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF814df6),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.7749, -122.4194),
          zoom: 11.0,
        ),
        markers: _markers,
      ),
    );
  }
}
