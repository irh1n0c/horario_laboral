import 'package:flutter/material.dart';

class MiBoton extends StatefulWidget {
  final VoidCallback onPressed;
  final Icon icon;
  final String textoOriginal; // Texto original
  final String textoAlternativo; // Texto alternativo
  final Color backgroundColor;
  final Color foregroundColor;

  const MiBoton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.textoOriginal,
    required this.textoAlternativo,
    this.backgroundColor =
        const Color.fromARGB(255, 255, 255, 255), // Color por defecto
    this.foregroundColor =
        const Color.fromARGB(255, 34, 34, 34), // Color de texto por defecto
  });

  @override
  _MiBotonState createState() => _MiBotonState();
}

class _MiBotonState extends State<MiBoton> {
  late Color botonColor;
  late String textoBoton; // Variable para el texto del botón

  @override
  void initState() {
    super.initState();
    botonColor = widget.backgroundColor; // Inicializa el color del botón
    textoBoton = widget.textoOriginal; // Inicializa el texto del botón
  }

  void cambiarEstado() {
    setState(() {
      // Alterna entre el color original y rojo
      botonColor = botonColor == widget.backgroundColor
          ? const Color.fromARGB(255, 65, 65, 65)
          : widget.backgroundColor;

      // Alterna entre el texto original y el alternativo
      textoBoton = textoBoton == widget.textoOriginal
          ? widget.textoAlternativo
          : widget.textoOriginal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        cambiarEstado(); // Cambiar el color y texto al presionar el botón
        widget.onPressed(); // Llamar a la función pasada
      },
      icon: widget.icon,
      label: Text(textoBoton), // Usar el texto que cambia
      style: ElevatedButton.styleFrom(
        backgroundColor: botonColor,
        foregroundColor: widget.foregroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
