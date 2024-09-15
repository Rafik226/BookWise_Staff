import 'package:bookwise_staff/screens/auth/reset_password_screen.dart';
import 'package:bookwise_staff/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:bookwise_staff/services/auth_service.dart';
import 'package:bookwise_staff/widgets/button.dart';
import 'package:bookwise_staff/widgets/snake_bar.dart';
import 'package:bookwise_staff/widgets/text_field_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String emailError = '';
  String passwordError = '';

  // Fonction de validation
  bool validateInputs() {
    bool isValid = true;
    setState(() {
      emailError = '';
      passwordError = '';

      if (emailController.text.isEmpty) {
        emailError = 'L\'adresse e-mail est obligatoire';
        isValid = false;
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text)) {
        emailError = 'Adresse e-mail invalide';
        isValid = false;
      }

      if (passwordController.text.isEmpty) {
        passwordError = 'Le mot de passe est obligatoire';
        isValid = false;
      } else if (passwordController.text.length < 6) {
        passwordError = 'Le mot de passe doit contenir au moins 6 caractères';
        isValid = false;
      }
    });
    return isValid;
  }

  void signInWithEmailAndPassword() async {
    if (!validateInputs()) return; // Valide les entrées avant de se connecter

    setState(() {
      isLoading = true; // Affiche un indicateur de chargement
    });

    String response = await AuthService().signInWithEmailAndPassword(
      context, // Ajoute context ici pour l'utilisation dans AuthService
      emailController.text,
      passwordController.text,
    );

    if (!mounted) return; // Vérifie si le widget est toujours monté

    setState(() {
      isLoading = false; // Arrête l'indicateur de chargement après la réponse
    });

    if (response == "Connexion réussie") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      showSnackBar(context, response);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: height / 3,
                  child: Image.asset("assets/logo.png"),
                ),
                // Champ pour l'adresse e-mail avec message d'erreur
                TextFieldInputs(
                  textEditingController: emailController,
                  hintText: 'Entrer votre adresse e-mail',
                  icon: Icons.email,
                  obscureText: false,
                  errorText: emailError, // Affichage des erreurs
                ),
                if (emailError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      emailError,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                // Champ pour le mot de passe avec message d'erreur
                TextFieldInputs(
                  textEditingController: passwordController,
                  hintText: 'Entrer votre mot de passe',
                  icon: Icons.lock,
                  obscureText: true,
                  errorText: passwordError, // Affichage des erreurs
                ),
                if (passwordError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      passwordError,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 20),
                // Bouton de connexion avec indicateur de chargement
                isLoading
                    ? const CircularProgressIndicator()
                    : MyButton(
                        onTapp: signInWithEmailAndPassword,
                        text: "Connexion avec E-mail",
                      ),
                const SizedBox(height: 20),
                // Lien pour la réinitialisation du mot de passe
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PasswordRecoveryScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Mot de passe oublié ?",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                SizedBox(height: height / 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
