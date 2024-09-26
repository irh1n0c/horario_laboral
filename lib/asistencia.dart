import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'card_tmp.dart'; 

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
      // Obtén el usuario actual
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Crea una nueva entrada en Firestore
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centrar verticalmente
        crossAxisAlignment: CrossAxisAlignment.center, // Centrar horizontalmente
        children: [
          // El CardBackground
          const Center(
            child: CardBackground(
              backgroundImage: 'assets/images/fondo.jpg', // Ruta de la imagen
              backgroundColor: Colors.grey, // Color de respaldo
              height: 200.0,
              child: Text(""), // Contenido dentro de la tarjeta
            ),
          ),
          const SizedBox(height: 20), // Espacio entre la tarjeta y el botón
          // El botón para registrar el tiempo
          ElevatedButton(
            onPressed: registrarTiempo,
            child: const Text('Registrar Tiempo'),
          ),
        ],
      ),
    );
  }
}
