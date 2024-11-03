import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationService {
  Future<void> getCurrentLocationAndSave() async {
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
}
