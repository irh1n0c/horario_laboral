import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login/login.dart';
import 'asistencia.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
    apiKey: "AIzaSyATHVsUvnz4fV6ooX-DfpAAEOQdj3j6T8Y",
    authDomain: "horario-fismet.firebaseapp.com",
    projectId: "horario-fismet",
    storageBucket: "horario-fismet.appspot.com",
    messagingSenderId: "1014966001535",
    appId: "1:1014966001535:web:bb00a0c2ed2b07d7e6844a",
    measurementId: "G-KXB76TQW9L"
    )
  ); // Inicializa Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fismet Forms App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: const BorderSide(color: Colors.grey, width: 0.0),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginP(),
        '/home': (context) =>
            RegistroTiempoPage(), // Nueva ruta para la clase HomePage
      },
    );
  }
}
