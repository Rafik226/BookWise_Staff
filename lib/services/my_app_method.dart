import 'package:flutter/material.dart';

class MyAppMethods {
  static Future<void> showErrorORWarningDialog({
    required BuildContext context,
    required String subtitle,
    required VoidCallback fct,
    bool isError = true,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isError ? 'Erreur' : 'Avertissement'),
          content: Text(subtitle),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                fct();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> imagePickerDialog({
    required BuildContext context,
    required VoidCallback cameraFCT,
    required VoidCallback galleryFCT,
    required VoidCallback removeFCT,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choisir l\'image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera),
                title: const Text('Caméra'),
                onTap: () {
                  Navigator.of(context).pop();
                  cameraFCT();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () {
                  Navigator.of(context).pop();
                  galleryFCT();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Supprimer'),
                onTap: () {
                  Navigator.of(context).pop();
                  removeFCT();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
