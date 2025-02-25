import 'package:flutter/material.dart';

class MiBoton extends StatefulWidget {
  final VoidCallback onPressed;
  final Icon icon;
  final String textoOriginal;
  final String textoAlternativo;
  final Color backgroundColor;
  final Color foregroundColor;

  const MiBoton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.textoOriginal,
    required this.textoAlternativo,
    this.backgroundColor = const Color.fromARGB(255, 230, 0, 0), // Fondo blanco
    this.foregroundColor = const Color.fromARGB(255, 212, 36, 36), // Texto negro
  });

  @override
  _MiBotonState createState() => _MiBotonState();
}

class _MiBotonState extends State<MiBoton> {
  late Color botonColor;
  late String textoBoton;

  @override
  void initState() {
    super.initState();
    botonColor = widget.backgroundColor;
    textoBoton = widget.textoOriginal;
  }

  void cambiarEstado() {
    setState(() {
      botonColor = botonColor == widget.backgroundColor
          ? const Color.fromARGB(255, 255, 208, 0)//boton marcado
          : widget.backgroundColor;

      textoBoton = textoBoton == widget.textoOriginal
          ? widget.textoAlternativo
          : widget.textoOriginal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        cambiarEstado();
        widget.onPressed();
      },
      icon: widget.icon,
      label: Text(textoBoton),
      style: ElevatedButton.styleFrom(
        backgroundColor: botonColor,
        foregroundColor: const Color.fromARGB(255, 255, 255, 255), //textos de los botones
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),
    );
  }
}
