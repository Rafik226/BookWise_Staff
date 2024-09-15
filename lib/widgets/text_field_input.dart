import 'package:flutter/material.dart';

class TextFieldInputs extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final IconData icon;

  const TextFieldInputs({
    super.key,
    required this.textEditingController,
    this.isPass = false,
    required this.hintText,
    required this.icon, required bool obscureText, required String errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextFormField(
        controller: textEditingController,
        obscureText: isPass,
        decoration: InputDecoration(
          labelText: hintText, // Label flottant
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black45),
          prefixIcon: Icon(icon, color: Colors.blue), // Couleur de l'icône
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          filled: true,
          fillColor: const Color(0xFFedf0f8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none, // Sans bordure par défaut
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(width: 2, color: Colors.blue),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(width: 2, color: Colors.blueAccent),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(width: 2, color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: const BorderSide(width: 2, color: Colors.redAccent),
          ),
        ),
        style: const TextStyle(color: Colors.black87), // Couleur du texte
        cursorColor: Colors.blue, // Couleur du curseur
      ),
    );
  }
}
