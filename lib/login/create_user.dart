import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tmpt/login_text.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  RegisterUser createState() => RegisterUser();
}

class RegisterUser extends State<Register> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instancia de FirebaseAuth

  // Método para registrar el usuario
  Future<void> _registerUser() async {
    try {
      // Crear un usuario en Firebase con correo y contraseña
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: userController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Obtener el usuario recién creado
      final User? user = userCredential.user;

      if (user != null) {
        // Usuario registrado exitosamente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario registrado: ${user.email}')),
        );

        // Redirigir a la pantalla anterior (login, por ejemplo)
        Navigator.pop(context);
      }
    } catch (e) {
      // Mostrar un mensaje de error si ocurre un problema
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar usuario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFieldInpute(
              textEditingController: userController,
              hintText: "Ingrese su correo:",
              icon: Icons.account_circle,
            ),
            const SizedBox(height: 20),
            TextFieldInpute(
              textEditingController: passwordController,
              hintText: "Ingrese su contraseña:",
              icon: Icons.lock,
              isPass: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerUser, // Llama al método para registrar
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003A75),
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 30.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 15,
                ),
              ),
              child: const Text('Registrarme'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    userController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
