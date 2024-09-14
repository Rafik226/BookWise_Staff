import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final VoidCallback onTapp;
  final String text;

  const MyButton({
    super.key,
    required this.onTapp,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SizedBox(
        width: double.infinity, // Le bouton occupe toute la largeur disponible
        child: ElevatedButton(
          onPressed: onTapp,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            shadowColor: Colors.blueAccent, // Couleur de l'ombre
            elevation: 5, // Élévation de l'ombre
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
