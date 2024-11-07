import 'package:flutter/material.dart';
import 'package:horario_fismet/asistencia.dart';
import 'login/login.dart'; // Importa tu pantalla de LoginP
import 'package:firebase_core/firebase_core.dart'; // Necesario para Firebase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase para la web con las credenciales del proyecto
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyCpsOkM5U1sm2P1HqQeUjWnefd47VQlxAA",
        authDomain: "horario-fismet.firebaseapp.com",
        projectId: "horario-fismet",
        storageBucket: "horario-fismet.appspot.com",
        messagingSenderId: "1014966001535",
        appId: "1:1014966001535:web:0ebf2c53c9b80b49e6844a",
        measurementId: "G-23NQJ448EL"),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Mi App de Login',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Ruta inicial
      routes: {
        '/': (context) =>
            const LoginP(), // Ruta principal, donde muestras el login
        '/home': (context) =>
            RegistroTiempoPage(), // Ruta para la pantalla principal (después del login)
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenido a la aplicación')),
      body: Center(
        child: Text('Pantalla Principal'),
      ),
    );
  }
}
