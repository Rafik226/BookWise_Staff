import 'package:bookwise_staff/constant/constant.dart';
import 'package:bookwise_staff/models/librarian_model.dart';
import 'package:bookwise_staff/screens/auth/login_screen.dart';
import 'package:bookwise_staff/screens/edit_profile_page.dart';
import 'package:bookwise_staff/screens/settings_screen.dart'; // Nouvelle page de paramètres
import 'package:bookwise_staff/services/my_app_method.dart';
import 'package:bookwise_staff/services/staff_service.dart';
import 'package:bookwise_staff/widgets/profile_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:page_transition/page_transition.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
  StaffModel? staffModel;

  Future<void> fetchStaffInfo() async {
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final staffProvider = Provider.of<StaffService>(context, listen: false);
    try {
      staffModel = await staffProvider.fetchStaffInfo();
    } catch (error) {
      await MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "An error has occurred: $error",
        fct: () {},
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    fetchStaffInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Vous êtes en mode anonyme.',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              child: const LoginScreen(),
                              type: PageTransitionType.bottomToTop,
                            ),
                          );
                        },
                        child: const Text('Se connecter'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Constants
                                  .primaryColor, // Couleur de la bordure
                              width: 5.0, // Largeur de la bordure
                            ),
                          ),
                          child: ClipOval(
                            child: staffModel!.profileImage != null
                                ? FadeInImage.assetNetwork(
                                    placeholder:
                                        'assets/logo.png', // Image de chargement
                                    image: staffModel!.profileImage!,
                                    fit: BoxFit
                                        .cover, // Ajustement de l'image dans le cercle
                                    imageErrorBuilder:
                                        (context, error, stackTrace) {
                                      return Image.asset(
                                          'assets/logo.png'); // Image par défaut en cas d'erreur
                                    },
                                  )
                                : Image.asset(
                                    'assets/logo.png', // Image par défaut si pas d'image réseau
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${staffModel!.firstName} ${staffModel!.lastName}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          staffModel!.email,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black.withOpacity(.6),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ProfileWidget(
                              icon: Icons.person,
                              title: 'Mon Profil',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditProfilePage(staff: staffModel!),
                                  ),
                                );
                              },
                            ),
                            ProfileWidget(
                              icon: Icons.settings,
                              title: 'Paramètre',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SettingsScreen(),
                                  ),
                                );
                              },
                            ),
                            ProfileWidget(
                              icon: Icons.share,
                              title: 'Partager',
                              onTap: () async {
                                
                              },
                            ),
                            ProfileWidget(
                              icon: Icons.logout,
                              title: 'Déconnexion',
                              onTap: () async {
                                await MyAppMethods.showErrorORWarningDialog(
                                  context: context,
                                  subtitle:
                                      "Êtes-vous sûr de vouloir vous déconnecter?",
                                  fct: () async {
                                    await FirebaseAuth.instance.signOut();
                                    Navigator.pushReplacement(
                                        context,
                                        PageTransition(
                                            child: const LoginScreen(),
                                            type: PageTransitionType
                                                .bottomToTop));
                                  },
                                  isError: false,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
