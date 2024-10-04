import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'card_tmp.dart'; 
import 'templates/button.dart';
//import 'templates/fonts.dart';
import 'templates/avatar.dart';

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
      appBar: AppBar(
        title: const Text(''),
      ),
      body: Stack(
        children: [
          // Posicionamos el texto en la parte superior derecha
          Positioned(
            top: 1.0,
            right: 70.0,
            child: TextWithBackground(
              text: 'Bienvenido, Jose',
              backgroundColor: const Color.fromARGB(255, 22, 50, 231),
              textStyle: const TextStyle(
                fontFamily: 'geometria',
                color: Color.fromARGB(255, 247, 246, 244),
                fontSize: 14.0,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          // Posición de la imagen circular
          const Positioned(
            top: 1.0,
            right: 20.0,
            child: CircularImage(
              imagePath: 'assets/images/jose.jpg',
              radius: 60.0,
            ),
          ),
          
          // Texto "Mi asistencia" posicionado a la izquierda
          const Positioned(
            top: 50.0,
            left: 20.0, // Margen izquierdo
            child: Text(
              'Mi asistencia',
              style: TextStyle(
                fontFamily: 'Lato',
                color: Color.fromARGB(255, 28, 28, 28),
                fontSize: 25.0,
              ),
            ),
          ),
          
          // Contenido principal con Positioned
          Positioned(
            top: 90.0, // Ajustado para dar espacio al texto
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // La tarjeta centrada
                const Center(
                  child: CardBackground(
                    backgroundImage: 'assets/images/fondo.jpg',
                    backgroundColor: Colors.grey,
                    height: 200.0,
                    child: Text(""),
                  ),
                ),
                const SizedBox(height: 10),
              //boton de asistencia
              ElevatedButton.icon(
              onPressed: registrarTiempo,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Marcar asistencia'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 22, 50, 231),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 3,
              ),
            ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
