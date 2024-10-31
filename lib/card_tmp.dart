import 'package:flutter/material.dart';

class CardBackground extends StatelessWidget {
  final String? backgroundImage; // Ruta de la imagen de fondo opcional
  final Color backgroundColor; // Color de fondo (en caso de no usar imagen)
  final double height; // Alto
  final Widget? child; // Nuevo parámetro para un widget hijo

  const CardBackground({
    super.key,
    this.backgroundImage, // Ruta de la imagen opcional
    required this.backgroundColor,
    required this.height,
    this.child, // Permitir un hijo opcional
  });

  @override
  Widget build(BuildContext context) {
    // Obtener el ancho de la pantalla
    double width = MediaQuery.of(context).size.width;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Bordes redondeados
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: width, // Ocupa todo el ancho de la pantalla
        height: height, // Ajustar la altura
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Mostrar la imagen si está presente, sino usar el color de fondo
            if (backgroundImage != null)
              Image.asset(
                backgroundImage!,
                fit:
                    BoxFit.cover, // Ajustar la imagen para cubrir todo el fondo
              )
            else
              Container(
                  color:
                      backgroundColor), // Usar color de fondo si no hay imagen

            // Contenido de la tarjeta (child)
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (child != null) child!, // Incluir el hijo si no es nulo
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
