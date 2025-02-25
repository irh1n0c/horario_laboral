import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:horario_fismet/login/create_user.dart';
import 'tmpt/login_text.dart';
import 'package:flutter/gestures.dart';

class LoginP extends StatefulWidget {
  const LoginP({super.key});

  @override
  LoginPState createState() => LoginPState();
}

class LoginPState extends State<LoginP> {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  void _checkUserSession() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Si el usuario ya está autenticado, lo redirigimos a la pantalla principal
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

  Future<void> _signIn() async {
    try {
      final email = userController.text.trim();
      final pass = passwordController.text.trim();

      if (email.isEmpty || pass.isEmpty) {
        _showErrorDialog("Los campos no pueden estar vacíos.");
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _showErrorDialog("Error en la autenticación: $e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("Aceptar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _header(context),
                _logo(context),
                TextFieldInpute(
                  textEditingController: userController,
                  hintText: "Ingrese su usuario:",
                  icon: Icons.account_circle,
                ),
                TextFieldInpute(
                  textEditingController: passwordController,
                  hintText: "Ingrese su contraseña:",
                  icon: Icons.lock,
                  isPass: true,
                  obscureText: _obscureText,
                  onObscureTextChanged: (bool value) {
                    setState(() {
                      _obscureText = value;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003A75),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 54.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 15,
                    ),
                  ),
                  child: const Text("Entrar"),
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    text: '¿No tienes cuenta?, ', // Primera parte del texto
                    style: const TextStyle(
                      fontSize: 14, // Tamaño de la fuente
                      color: Color.fromARGB(255, 41, 41, 41), // Color del texto
                    ),
                    children: [
                      TextSpan(
                        text: 'Registrate aqui.', // Segunda parte del texto
                        style: const TextStyle(
                          color: Color(
                              0xFF003A75), // Color diferente para esta parte
                          // Subrayar para indicar clic
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Aquí navegas a otra página
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Register(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return const Column(
      children: [
        Text(
          "",
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _logo(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return SizedBox(
      width: double.infinity,
      height: height / 2.7,
      child: Image.asset("assets/images/asistencia.png"),
    );
  }
}
