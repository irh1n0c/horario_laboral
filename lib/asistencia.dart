import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'card_tmp.dart';
import 'templates/button.dart';
//import 'templates/fonts.dart';
import 'templates/avatar.dart';
import 'login/tmpt/clock_widget.dart';

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

  Future<void> registrarTiempo() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('registros_tiempo').add({
          'userId': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });
        print('Tiempo registrado con éxito');
      } else {
        print('No hay usuario autenticado');
      }
    } catch (e) {
      print('Error al registrar el tiempo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          // Texto en la parte superior derecha
          Positioned(
            top: 1.0,
            right: 70.0,
            child: TextWithBackground(
              text: 'Bienvenido, Jose',
              backgroundColor: const Color(0xFF5ebb55),
              textStyle: const TextStyle(
                fontFamily: 'geometria',
                color: Color.fromARGB(255, 247, 246, 244),
                fontSize: 14.0,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          // Imagen circular
          const Positioned(
            top: 1.0,
            right: 20.0,
            child: CircularImage(
              imagePath: 'assets/images/jose.jpg',
              radius: 60.0,
            ),
          ),
          // Texto "Mi asistencia" a la izquierda
          const Positioned(
            top: 50.0,
            left: 20.0,
            child: Text(
              'Mi asistencia',
              style: TextStyle(
                fontFamily: 'Lato',
                color: Color(0xFF5ebb55),
                fontSize: 20.0,
              ),
            ),
          ),
          //1er box
          const Positioned(
            top: 90.0,
            left: 0,
            right: 0,
            child: Center(
              child: CardBackground(
                backgroundColor: Color.fromARGB(255, 32, 32, 32),
                height: 200.0,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Arequipa", // Reemplaza con la ubicación real
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      Text(
                        '25 °C', // Reemplaza con la temperatura real
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      Text(
                        "Soleado", // Reemplaza con la condición real
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          //2do box
          const Positioned(
            top: 300.0,
            left: 0,
            right: 0,
            child: ClockWidget(), // Aquí se muestra la hora
          ),
          const Positioned(
            top: 510.0, // Ajusta según sea necesario
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CardBackground(
                      backgroundColor: Color.fromARGB(255, 32, 32, 32),
                      height: 100.0, // Ajusta la altura según necesites
                      child: Text("Izquierda"),
                    ),
                  ),
                  SizedBox(width: 10), // Espacio entre los dos
                  Expanded(
                    child: CardBackground(
                      backgroundColor: Color.fromARGB(255, 32, 32, 32),
                      height: 100.0, // Ajusta la altura según necesites
                      child: Text("Derecha"),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botón de asistencia
          Positioned(
            bottom: 20.0, // Ajusta esto según tus necesidades
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          registrarTiempo, // Función para el botón de la izquierda
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('ENTRADA'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5ebb55),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // Espacio entre los botones
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          registrarTiempo, // Función para el botón de la derecha
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('SALIDA'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5ebb55),
                        foregroundColor: Colors.white,
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
            ),
          ),
        ],
      ),
    );
  }
}
