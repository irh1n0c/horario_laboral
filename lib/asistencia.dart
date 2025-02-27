import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'login/tmpt/clock_widget.dart';
import 'mapa.dart';
import 'login/tmpt/cliima_local.dart';
import 'package:audioplayers/audioplayers.dart';
import 'excel_all_user.dart';
import 'login/tmpt/glass_button.dart';
import 'call_mapa.dart';
import 'excel_export.dart';
import 'templates/boton_cambio_color.dart';
import 'boton_viajes.dart';

final LocationService locationService = LocationService();
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
          await audioPlayer.play(AssetSource('sounds/pick-92276.mp3'));
          debugPrint('Registrando entrada...');
          await diaRef.set({
            'alias': alias,
            'entrada': FieldValue.serverTimestamp(),
            'dispositivo': dispositivo, // Agregar dispositivo
          }, SetOptions(merge: true));
          debugPrint(
              'Entrada registrada con éxito con alias $alias desde el dispositivo $dispositivo');
        } else if (tipoAccion == 'Salida') {
          await audioPlayer.play(AssetSource('sounds/pick-92276.mp3'));
          debugPrint('Registrando salida...');
          await diaRef.update({
            'salida': FieldValue.serverTimestamp(),
            'dispositivo': dispositivo, // Agregar dispositivo
          });
          debugPrint(
              'Salida registrada con éxito con alias $alias desde el dispositivo $dispositivo');
        }
      } else {
        debugPrint('No hay usuario autenticado o el correo no es válido');
      }
    } catch (e) {
      debugPrint('Error al registrar el tiempo: $e');
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
        decoration: const BoxDecoration(
            gradient: RadialGradient(
          colors: [Color(0xff0575e6), Color(0xff021b79)],
          stops: [0, 1],
          center: Alignment.center,
        )),
        child: Column(
          children: [
            PreferredSize(
              preferredSize: const Size.fromHeight(130.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 1, 29, 105),
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
                          color: Color(0xFFffffff),
                          //fontWeight: FontWeight.bold,
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
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0, vertical: 8.0),
                                child: Text(
                                  'Bienvenido ${capitalize(alias)}', // Usar la función para capitalizar
                                  style: const TextStyle(
                                    fontFamily: 'geometria',
                                    color: Color(0xFF1a352e),
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              FutureBuilder<bool>(
                                future: DefaultAssetBundle.of(context)
                                    .load('assets/images/$alias.jpg')
                                    .then((_) => true)
                                    .catchError((_) => false),
                                builder: (context, snapshot) {
                                  return CircleAvatar(
                                    radius: 25.0,
                                    backgroundImage: AssetImage(
                                      snapshot.hasData && snapshot.data!
                                          ? 'assets/images/$alias.jpg'
                                          : 'assets/images/default.jpg',
                                    ),
                                  );
                                },
                              )
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
                                  color: Color(0xFFffffff),
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
                                    color: Color(0xFFffffff),
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
                              onTap: () async {
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  // Lista de UIDs autorizados para acceder a TablaAsistenciasPageAll
                                  final authorizedUsers = [
                                    'OQl7UyLgI6OjKPuCrEgRNovpXQ52',
                                    'JEtd2gpNfQWUQrM4T4ElYAd24km1',
                                    'OYyb3tmd70gUXh7RotUoXZCtBi72'
                                  ];

                                  if (authorizedUsers.contains(user.uid)) {
                                    // Si el usuario está autorizado, ir a TablaAsistenciasPageAll
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            TablaAsistenciasPageAll(),
                                      ),
                                    );
                                  } else {
                                    // Si no está autorizado, ir a TablaAsistenciasPage
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TablaAsistenciasPage(),
                                      ),
                                    );
                                  }
                                }
                              },
                              child: FrostedGlassBox(
                                theWidth: size.width *
                                    0.7, // Ancho responsivo al 80% de la pantalla
                                theHeight: size.height *
                                    0.15, // Altura al 15% de la pantalla
                                theChild: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Text(
                                        "Tabla de asistencias",
                                        style: TextStyle(
                                          fontFamily: 'geometria',
                                          color: Color(0xFFffffff),
                                        ),
                                      ),
                                    ),
                                    // Espaciado entre el título y el Row
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons
                                              .format_align_left, // Icono de alineación
                                          color: Color(0xFFffffff),
                                        ),
                                        SizedBox(
                                            width:
                                                2), // Espacio entre el icono y el texto
                                        Text(
                                          "Calendario del mes",
                                          style: TextStyle(
                                            fontFamily: 'geometria',
                                            color: Color(0xFFffffff),
                                            fontSize: 12.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              // Use Column for vertical arrangement instead of Row
                              children: [
                                // First widget
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const GoogleMapsTestPage(),
                                      ),
                                    );
                                  },
                                  child: FrostedGlassBox(
                                    theWidth: size.width * 0.45,
                                    theHeight: size.height * 0.07,
                                    theChild: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: const Color.fromARGB(
                                                      255, 255, 255, 255),
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: const Text(
                                              "Marcar mi ubicación",
                                              style: TextStyle(
                                                fontFamily: 'geometria',
                                                color: Color(0xFFffffff),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Duplicated widget (second widget)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              FormularioViaje()),
                                    );
                                  },
                                  child: FrostedGlassBox(
                                    theWidth: size.width * 0.45,
                                    theHeight: size.height * 0.07,
                                    theChild: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                'assets/images/montanas.png', // Ruta de la imagen en assets
                                                width:
                                                    40, // Ajusta el tamaño según necesites
                                                height: 40,
                                              ),
                                              const SizedBox(
                                                  width:
                                                      10), // Espacio entre la imagen y el texto
                                              Column(
                                                children: [
                                                  Text(
                                                    'Vámonos de viaje',
                                                    style: TextStyle(
                                                      fontFamily: 'geometria',
                                                      fontSize:
                                                          size.width * 0.03,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center, // Centra los elementos en la fila
                                                    children: [
                                                      ShaderMask(
                                                        shaderCallback:
                                                            (Rect bounds) {
                                                          return const LinearGradient(
                                                            colors: [
                                                              Colors.yellow,
                                                              Color.fromARGB(
                                                                  255,
                                                                  109,
                                                                  216,
                                                                  248)
                                                            ], // Degradado amarillo-verde
                                                            begin: Alignment
                                                                .topLeft,
                                                            end: Alignment
                                                                .bottomRight,
                                                          ).createShader(
                                                              bounds);
                                                        },
                                                        child: Text(
                                                          'BUENA SUERTE',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'geometria',
                                                            fontSize:
                                                                size.width *
                                                                    0.03,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color: Colors
                                                                .white, // Necesario, pero será reemplazado por el degradado
                                                          ),
                                                        ),
                                                      ),
                                                      // const SizedBox(
                                                      //     width:
                                                      //         8), // Espacio entre el texto y el emoji
                                                      // const Text(
                                                      //   '☠️', // Emoji de carita feliz
                                                      //   style: TextStyle(
                                                      //       fontSize:
                                                      //           12), // Tamaño del emoji
                                                      // ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),

                      // Botones de asistencia
                      Row(
                        children: [
                          Expanded(
                            child: MiBoton(
                              onPressed: () =>
                                  registrarTiempo(context, 'Salida'),
                              icon: const Icon(
                                Icons.check_circle,
                                color: Color.fromARGB(255, 255, 255,
                                    255), // Cambia este color al que desees
                              ),

                              textoOriginal:
                                  'Salir', // Texto original del botón
                              textoAlternativo:
                                  'A descansar', // Texto alternativo del botón
                              backgroundColor: const Color.fromARGB(
                                  255, 255, 11, 121), // Color de fondo
                              foregroundColor: const Color.fromARGB(
                                  255, 255, 255, 255), // Color del texto
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Expanded(
                            child: MiBoton(
                              onPressed: () async {
                                registrarTiempo(context, 'Entrada');
                                await locationService
                                    .getCurrentLocationAndSave();
                              },
                              icon: const Icon(
                                Icons.check_circle,
                                color: Color.fromARGB(255, 255, 255,
                                    255), // Cambia este color al que desees
                              ),
                              textoOriginal:
                                  'Entrar', // Texto original del botón
                              textoAlternativo:
                                  'Buena suerte!', // Texto alternativo del botón
                              backgroundColor: const Color.fromARGB(
                                  255, 255, 11, 121), // Color de fondo
                              foregroundColor: const Color.fromARGB(
                                  255, 254, 254, 254), // Color del texto
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
