import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        title: const Text('Registro de Tiempo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: registrarTiempo,
          child: const Text('Registrar Tiempo'),
        ),
      ),
    );
  }
}