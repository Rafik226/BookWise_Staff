import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Connexion par adresse e-mail et mot de passe
  Future<String> signInWithEmailAndPassword(
      String email, String password) async {
    String response = "Une erreur est survenue !";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
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
      }
    } catch (e) {
      response = "Erreur : ${e.toString()}";
    }
    return response;
  }
}
