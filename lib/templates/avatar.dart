import 'package:flutter/material.dart';

class CircularImage extends StatelessWidget {
  final String imagePath; // Ruta de la imagen en assets
  final double radius; // Radio de la imagen circular

  const CircularImage({super.key, required this.imagePath, this.radius = 50.0}); // Constructor

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        imagePath,
        width: radius * 0.6,
        height: radius * 0.6,
        fit: BoxFit.cover,
      ),
    );
  }
}
