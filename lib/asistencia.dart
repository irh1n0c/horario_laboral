import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'card_tmp.dart';
import 'templates/button.dart';
import 'templates/avatar.dart';
import 'login/tmpt/clock_widget.dart';
import 'mapa.dart';
import 'login/tmpt/cliima_local.dart';
import 'excel_export.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RegistroTiempoPage(),
    );
  }
}

class RegistroTiempoPage extends StatelessWidget {
  const RegistroTiempoPage({super.key});

  Future<void> registrarTiempo(String tipoAccion) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null && user.email != null) {
        String email = user.email!;
        String alias = email.split('@')[0];

        String fecha =
            DateTime.now().toLocal().toIso8601String().substring(0, 10);

        DocumentReference diaRef = FirebaseFirestore.instance
            .collection('registros_tiempo')
            .doc(user.uid)
            .collection('dias')
            .doc(fecha);

        if (tipoAccion == 'Entrada') {
          print('Registrando entrada...');
          await diaRef.set({
            'alias': alias,
            'entrada': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          print('Entrada registrada con éxito con alias $alias');
        } else if (tipoAccion == 'Salida') {
          print('Registrando salida...');
          await diaRef.update({
            'salida': FieldValue.serverTimestamp(),
          });
          print('Salida registrada con éxito con alias $alias');
        }
      } else {
        print('No hay usuario autenticado o el correo no es válido');
      }
    } catch (e) {
      print('Error al registrar el tiempo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: const Color(0xffc5beaa),
        child: Column(
          children: [
            PreferredSize(
              preferredSize: const Size.fromHeight(130.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xffb32a48),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(15)),
                ),
                child: Column(
                  children: [
                    AppBar(
                      title: const Text(
                        'Horario Fismet',
                        style: TextStyle(
                          color: Color(0xffc5beaa),
                          fontFamily: 'Geometria',
                        ),
                      ),
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 1.0, horizontal: 10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextWithBackground(
                                text: 'Hola bienvenido',
                                backgroundColor: const Color(0xffc5beaa),
                                textStyle: const TextStyle(
                                  fontFamily: 'geometria',
                                  color: Color(0xFFb32a48),
                                  fontSize: 14.0,
                                ),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              const CircularImage(
                                imagePath: 'assets/images/user.jpg',
                                radius: 80.0,
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
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Mi asistencia',
                        style: TextStyle(
                          fontFamily: 'geometria',
                          color: Color(0xff28356a),
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5.0),
                      const WeatherWidget(),
                      const SizedBox(height: 5.0),
                      const ClockWidget(),
                      const SizedBox(height: 5.0),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const TablaAsistenciasPage(),
                                  ),
                                );
                              },
                              child: CardBackground(
                                backgroundColor: const Color(0xff28356a),
                                height: size.height * 0.15,
                                child: const Center(
                                  child: Text(
                                    "Control de usuarios",
                                    style: TextStyle(
                                      color: Color(0xFFffffff),
                                      fontFamily:
                                          'Geometria', // Añade tu fuente aquí
                                    ),
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
                                backgroundColor: const Color(0xff28356a),
                                height: size.height * 0.15,
                                child: const Center(
                                  child: Text(
                                    "Marcar mi ubicación",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Geometria',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => registrarTiempo('Salida'),
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: Colors
                                    .white, // Cambia el color del ícono aquí
                              ),
                              label: const Text(
                                'Salida',
                                style: TextStyle(
                                  color: Colors
                                      .white, // Cambia el color del texto aquí
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffb32a48),
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
                              onPressed: () => registrarTiempo('Entrada'),
                              icon: const Icon(
                                Icons.check_circle_outline,
                                color: Colors
                                    .white, // Cambia el color del ícono aquí
                              ),
                              label: const Text(
                                'Entrada',
                                style: TextStyle(
                                  color: Colors
                                      .white, // Cambia el color del texto aquí
                                  fontSize: 16,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xffb32a48),
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
