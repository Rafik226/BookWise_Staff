import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Connexion par adresse e-mail et mot de passe
  Future<String> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    String response = "Une erreur est survenue !";
    try {
      // Vérification des champs avant l'envoi de la requête
      if (email.isEmpty) {
        return "L'adresse e-mail ne peut pas être vide";
      }
      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        return "Adresse e-mail invalide";
      }
      if (password.isEmpty) {
        return "Le mot de passe ne peut pas être vide";
      }
      if (password.length < 6) {
        return "Le mot de passe doit contenir au moins 6 caractères";
      }

      // Affichage d'un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      // Tentative de connexion
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      response = "Connexion réussie";

      User? user = userCredential.user;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('staff').doc(user.uid).get();

        if (!userDoc.exists) { // Vérifiez si le document existe
          response = 'Connexion non autorisée';
          await _auth.signOut();
        } else {
          response = 'Connexion réussie';
        }
      }

      // Fermer l'indicateur de chargement
      Navigator.of(context).pop();
      
    } catch (e) {
      // Gestion des erreurs
      Navigator.of(context).pop();  // Fermer l'indicateur de chargement
      response = "Erreur : ${e.toString()}";
    }

    return response;
  }
}
