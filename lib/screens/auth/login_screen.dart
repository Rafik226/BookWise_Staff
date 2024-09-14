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

void signInWithEmailAndPassword() async {
  setState(() {
    isLoading = true; // Montre un indicateur de chargement
  });

  String response = await AuthService().signInWithEmailAndPassword(
    emailController.text,
    passwordController.text,
  );

  if (!mounted) return; // Vérifie si le widget est toujours monté avant d'appeler setState

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
                // Champ pour l'adresse e-mail
                TextFieldInputs(
                  textEditingController: emailController,
                  hintText: 'Entrer votre adresse e-mail',
                  icon: Icons.email,
                  obscureText: false,
                ),
                // Champ pour le mot de passe
                TextFieldInputs(
                  textEditingController: passwordController,
                  hintText: 'Entrer votre mot de passe',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                SizedBox(height: 20),
                MyButton(
                  onTapp: signInWithEmailAndPassword,
                  text: "Connexion avec E-mail",
                ),
                SizedBox(height: 20),
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
