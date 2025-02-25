import 'package:flutter/material.dart';

class TextWithBackground extends StatelessWidget {
  final String text; // Texto que será mostrado
  final Color backgroundColor; // Color de fondo
  final TextStyle? textStyle; // Estilo opcional del texto
  final BorderRadius borderRadius; // Nuevo parámetro para bordes redondeados

  const TextWithBackground({
    super.key,
    required this.text,
    this.backgroundColor = const Color.fromARGB(255, 255, 254, 254), // Color de fondo por defecto
    this.textStyle,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)), // Valor por defecto
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor, // Color de fondo
        borderRadius: borderRadius, // Uso del nuevo parámetro borderRadius
      ),
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Text(
        text,
        style: textStyle ??
            const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 18.0,
            ), // Estilo del texto por defecto si no se pasa uno
      ),
    );
  }
}
