import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'card_tmp.dart';
import 'templates/button.dart';
import 'templates/avatar.dart';
import 'login/tmpt/clock_widget.dart';
import 'mapa.dart';
import 'login/tmpt/cliima_local.dart';

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
        // Obtener el alias a partir del correo electrónico
        String email = user.email!;
        String alias =
            email.split('@')[0]; // Extraer la parte antes de @fismet.com

        // Obtener la fecha actual
        String fecha =
            DateTime.now().toLocal().toIso8601String().substring(0, 10);

        // Referencia al documento en Firestore usando el UID
        DocumentReference diaRef = FirebaseFirestore.instance
            .collection('registros_tiempo')
            .doc(user.uid) // Seguir usando el UID como identificador único
            .collection('dias')
            .doc(fecha);

        // Registrar la entrada o salida junto con el alias
        if (tipoAccion == 'Entrada') {
          await diaRef.set({
            'alias': alias, // Guardar el alias dentro del documento
            'entrada': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          print('Entrada registrada con éxito con alias $alias');
        } else if (tipoAccion == 'Salida') {
          await diaRef.set({
            'alias': alias, // Guardar el alias dentro del documento
            'salida': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
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
      //backgroundColor: const Color(0xFFF3F3F4),
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(140.0), // Ajusta la altura según lo necesites
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 229, 229, 229),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
          ),
          child: Column(
            children: [
              AppBar(
                title: const Text('Horario Fismet'),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Parte superior: Bienvenida y avatar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWithBackground(
                          text: 'Bienvenido, Jose',
                          backgroundColor: const Color(0xFF5ebb55),
                          textStyle: const TextStyle(
                            fontFamily: 'geometria',
                            color: Color.fromARGB(255, 247, 246, 244),
                            fontSize: 14.0,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        const CircularImage(
                          imagePath: 'assets/images/jose.jpg',
                          radius: 80.0, // Ajusta el tamaño según sea necesario
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Mi asistencia',
                style: TextStyle(
                  fontFamily: 'Lato',
                  color: Color(0xFF4dc7d5),
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10.0),
              // Widget de reloj
              const WeatherWidget(),
              const SizedBox(height: 5.0),
              // Tarjeta de información del clima
              // CardBackground(
              //   backgroundColor: const Color(0xFFEFECF0),
              //   height: size.height * 0.2,
              //   child: const Padding(
              //     padding: EdgeInsets.all(10.0),
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Text(
              //           "Arequipa", // Reemplaza con la ubicación real
              //           style:
              //               TextStyle(color: Color(0xFF814df6), fontSize: 20),
              //         ),
              //         Text(
              //           '25 °C', // Reemplaza con la temperatura real
              //           style:
              //               TextStyle(color: Color(0xFF814df6), fontSize: 24),
              //         ),
              //         Text(
              //           "Soleado", // Reemplaza con la condición real
              //           style:
              //               TextStyle(color: Color(0xFF814df6), fontSize: 16),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              const SizedBox(height: 5.0),

              // Widget de reloj
              const ClockWidget(),
              const SizedBox(height: 5.0),

              // Mapa y botones
              Row(
                children: [
                  Expanded(
                    child: CardBackground(
                      backgroundColor: const Color(0xFF814df6),
                      height: size.height * 0.15,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Control de Asistencia",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    13, // Ajusta el tamaño del texto según lo necesites
                                fontWeight:
                                    FontWeight.bold, // Estilo del título
                              ),
                            ),
                            SizedBox(
                                height:
                                    5), // Espacio entre el título y el subtítulo
                            Text(
                              "Asistencia diaria y gestión de horarios",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    9, // Ajusta el tamaño del subtítulo según lo necesites
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
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
                        backgroundColor: const Color(0xFF814df6),
                        height: size.height * 0.15,
                        child: const Center(
                          child: Text(
                            "Ubicarme en el mapa",
                            style: TextStyle(color: Colors.white),
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
                      onPressed: () => registrarTiempo('Salida'),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Salida'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFedbf40),
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
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Entrada'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFedbf40),
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
    );
  }
}
