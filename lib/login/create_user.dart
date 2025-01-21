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
          children: [
            Expanded(child: _logo(context)),
            TextFieldInpute(
              textEditingController: userController,
              hintText: "usuario@fismet.com",
              icon: Icons.account_circle,
            ),
            const SizedBox(height: 5),
            TextFieldInpute(
              textEditingController: passwordController,
              hintText: "contraseña de 6 digitos.",
              icon: Icons.lock,
              isPass: true,
            ),
            const SizedBox(height: 10),
            Flexible(
              child: ElevatedButton(
                onPressed: _registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 25, 47, 150),
                  foregroundColor: Colors.white,
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

  Widget _logo(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return SizedBox(
      width: double.infinity,
      height: height / 2.7,
      child: Image.asset("assets/images/login_create.png"),
    );
  }
}
