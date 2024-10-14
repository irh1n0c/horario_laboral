import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'card_tmp.dart';
import 'templates/button.dart';
//import 'templates/fonts.dart';
import 'templates/avatar.dart';
import 'login/tmpt/clock_widget.dart';
import 'maps_google.dart';

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
      if (user != null) {
        // Obtenemos la fecha actual en formato yyyy-MM-dd
        String fecha =
            DateTime.now().toLocal().toIso8601String().substring(0, 10);

        // Referencia al documento del día en la subcolección 'dias'
        DocumentReference diaRef = FirebaseFirestore.instance
            .collection('registros_tiempo')
            .doc(user.uid)
            .collection('dias')
            .doc(fecha);

        // Dependiendo del tipo de acción, registramos la entrada o salida
        if (tipoAccion == 'Entrada') {
          await diaRef.set({
            'entrada': FieldValue
                .serverTimestamp(), // Si es entrada, creamos el campo 'entrada'
          }, SetOptions(merge: true));
          print('Entrada registrada con éxito');
        } else if (tipoAccion == 'Salida') {
          await diaRef.set({
            'salida': FieldValue
                .serverTimestamp(), // Si es salida, actualizamos el campo 'salida'
          }, SetOptions(merge: true));
          print('Salida registrada con éxito');
        }
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
                color: Color(0xFF4dc7d5),
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
          Positioned(
            top: 510.0, // Ajusta según sea necesario
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 100.0, // Altura fija
                      child: Stack(
                        children: [
                          // Imagen
                          Image.asset(
                            'assets/images/wall1.jpg',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 100.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10), // Espacio entre los dos
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GoogleMapsTestPage(),
                        ),
                      );
                    },
                    child: const SizedBox(
                      // Cambiado de CardBackground a SizedBox
                      width: 150.0, // Ajusta el ancho según sea necesario
                      child: CardBackground(
                        backgroundColor: Color(0xFFd7b740),
                        height: 100.0, // Ajusta la altura según necesites
                        child: Center(
                          // Centra el texto dentro del CardBackground
                          child: Text("Ubicarme en el mapa"),
                        ),
                      ),
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
                      onPressed: () => registrarTiempo(
                          'Salida'), // Función para registrar salida
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Salida'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFd286a5),
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => registrarTiempo(
                          'Entrada'), // Función para registrar entrada
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Entrada'),
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
