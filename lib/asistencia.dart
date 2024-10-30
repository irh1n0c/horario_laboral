import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'card_tmp.dart';
import 'login/tmpt/clock_widget.dart';
import 'mapa.dart';
import 'login/tmpt/cliima_local.dart';
import 'package:audioplayers/audioplayers.dart';
import 'excel_all_user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: RegistroTiempoPage(),
    );
  }
}

class RegistroTiempoPage extends StatelessWidget {
  RegistroTiempoPage({super.key});
  final AudioPlayer audioPlayer = AudioPlayer();
  String capitalize(String s) =>
      s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);
  Future<void> registrarTiempo(BuildContext context, String tipoAccion) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && user.email != null) {
        // Obtener el alias a partir del correo electrónico
        String email = user.email!;
        String alias =
            email.split('@')[0]; // Extraer la parte antes de @fismet.com

        // Obtener la fecha actual
        String fecha =
            DateTime.now().toLocal().toIso8601String().substring(0, 10);

        // Obtener información del dispositivo
        String dispositivo = await _obtenerInformacionDispositivo(context);

        // Referencia al documento en Firestore usando el UID
        DocumentReference diaRef = FirebaseFirestore.instance
            .collection('registros_tiempo')
            .doc(user.uid) // Seguir usando el UID como identificador único
            .collection('dias')
            .doc(fecha);

        // Registrar la entrada o salida junto con el alias y el dispositivo
        if (tipoAccion == 'Entrada') {
          await audioPlayer.play(AssetSource('sounds/open.mp3'));
          print('Registrando entrada...');
          await diaRef.set({
            'alias': alias,
            'entrada': FieldValue.serverTimestamp(),
            'dispositivo': dispositivo, // Agregar dispositivo
          }, SetOptions(merge: true));
          print(
              'Entrada registrada con éxito con alias $alias desde el dispositivo $dispositivo');
        } else if (tipoAccion == 'Salida') {
          await audioPlayer.play(AssetSource('sounds/closed.mp3'));
          print('Registrando salida...');
          await diaRef.update({
            'salida': FieldValue.serverTimestamp(),
            'dispositivo': dispositivo, // Agregar dispositivo
          });
          print(
              'Salida registrada con éxito con alias $alias desde el dispositivo $dispositivo');
        }
      } else {
        print('No hay usuario autenticado o el correo no es válido');
      }
    } catch (e) {
      print('Error al registrar el tiempo: $e');
    }
  }

  Future<String> _obtenerInformacionDispositivo(BuildContext context) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String dispositivo;
    if (Theme.of(context).platform == TargetPlatform.android) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      dispositivo =
          'Android ${androidInfo.version.release} (${androidInfo.model})';
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      dispositivo = 'iOS ${iosInfo.systemVersion} (${iosInfo.model})';
    } else {
      dispositivo = 'Dispositivo desconocido';
    }
    return dispositivo;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    User? user = FirebaseAuth.instance.currentUser;

    // Obtener el alias a partir del correo electrónico
    String alias = user?.email?.split('@')[0] ?? 'Usuario';

    return Scaffold(
      body: Container(
        color: const Color(0xFF222222), // Cambia este color al que desees
        child: Column(
          children: [
            PreferredSize(
              preferredSize: const Size.fromHeight(130.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 61, 61, 61),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(18)),
                ),
                child: Column(
                  children: [
                    AppBar(
                      title: const Text(
                        'Asistencia Fismet',
                        style: TextStyle(
                          fontFamily: 'geometria',
                          color: Color(0xfffaf3e1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: Colors.transparent,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xffff6e1f),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0, vertical: 8.0),
                                child: Text(
                                  'Bienvenido ${capitalize(alias)}', // Usar la función para capitalizar
                                  style: const TextStyle(
                                    fontFamily: 'geometria',
                                    color: Color(0xFFfaf3e1),
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              CircleAvatar(
                                backgroundImage:
                                    AssetImage('assets/images/${alias}.jpg'),
                                radius:
                                    25.0, // Ajusta el tamaño de la imagen si es necesario
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await FirebaseAuth.instance.signOut();
                              if (context.mounted) {
                                Navigator.pushReplacementNamed(context,
                                    '/'); // Ajusta la ruta a tu pantalla de inicio de sesión
                              }
                            },
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.logout,
                                  color: Color.fromARGB(255, 140, 142, 150),
                                  size:
                                      22.0, // Ajusta el tamaño del icono si es necesario
                                ),
                                SizedBox(
                                    width:
                                        5), // Espacio entre el icono y el texto
                                Text(
                                  'Cerrar sesión',
                                  style: TextStyle(
                                    fontFamily: 'geometria',
                                    color: Color.fromARGB(255, 140, 142, 150),
                                    fontSize: 16.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      // Widget de reloj
                      const WeatherWidget(),
                      const SizedBox(height: 5.0),
                      const ClockWidget(),
                      const SizedBox(height: 5.0),

                      // Mapa y botones
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TablaAsistenciasPageAll(),
                                  ),
                                );
                              },
                              child: CardBackground(
                                backgroundColor: const Color(0xffC5B89E),
                                height: size.height * 0.15,
                                child: const Center(
                                  child: Text(
                                    "Tabla de asistencias",
                                    style: TextStyle(
                                        fontFamily: 'geometria',
                                        color: Color(0xFF222222)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => GoogleMapsTestPage(),
                                  ),
                                );
                              },
                              child: CardBackground(
                                backgroundColor: const Color(0xffC5B89E),
                                height: size.height * 0.15,
                                child: const Center(
                                  child: Text(
                                    "Marcar mi ubicación",
                                    style: TextStyle(
                                        fontFamily: 'geometria',
                                        color: Color(0xFF222222)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),

                      // Botones de asistencia
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  registrarTiempo(context, 'Salida'),
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Salida'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffff6e1f),
                                foregroundColor: const Color(
                                    0xFFfaf3e1), // Cambia el color del texto aquí
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  registrarTiempo(context, 'Entrada'),
                              icon: const Icon(Icons.check_circle),
                              label: const Text('Entrada'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffff6e1f),
                                foregroundColor: const Color(
                                    0xFFfaf3e1), // Cambia el color del texto aquí
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
