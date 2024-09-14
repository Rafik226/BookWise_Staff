import 'package:bookwise_staff/screens/notification_screen.dart';
import 'package:bookwise_staff/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:bookwise_staff/models/dashboard_button.dart';
import 'package:bookwise_staff/widgets/dashbord_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<bool> isAdmin() async {
    // Récupérer l'utilisateur connecté
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('staff')
          .doc(user.uid)
          .get();
      // Vérifier le rôle de l'utilisateur
      String role = userDoc['role'];
      return role == "admin";
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return FutureBuilder<bool>(
      future: isAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final dashboardButtons =
            DashboardButtonsModel.dashboardBtnList(context);

        if (snapshot.data == true) {
          final adminButtons =
              DashboardButtonsModel.dashboardBtnListForAdmin(context);
          dashboardButtons.addAll(adminButtons);
        }

        return Scaffold(
          body: SingleChildScrollView(
            child: Container(
              color: Colors.indigo,
              width: width,
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(),
                    height: height * 0.23,
                    width: width,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 35,
                              left: 20,
                              right: 20,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Icone cliquable pour la cloche
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const NotificationScreen(), // Remplacez NotificationScreen par la page de destination souhaitée
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.notifications,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                // Image cliquable
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            const ProfileScreen(), // Remplacez ProfileScreen par la page de destination souhaitée
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.white,
                                      image: const DecorationImage(
                                        image: AssetImage("assets/2.png"),
                                        fit: BoxFit
                                            .cover, // Assurez-vous que l'image couvre bien le conteneur
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(
                              top: 20,
                              left: 30,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Bookboard",
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Text("by Rafik & Donald",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white54,
                                      letterSpacing: 1,
                                    ))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ClipRRect(
                    // Permet de couper tout ce qui dépasse du cadre blanc
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    child: Container(
                      color: Colors.white,
                      width: width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0), // Ajout d'un padding ici
                        child: SizedBox(
                          height: height *
                              0.75, // Hauteur limitée pour éviter le débordement
                          child: GridView.builder(
                            itemCount: dashboardButtons.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1,
                              crossAxisSpacing:
                                  10.0, // Espacement horizontal entre les cartes
                              mainAxisSpacing:
                                  10.0, // Espacement vertical entre les cartes
                            ),
                            itemBuilder: (context, index) {
                              return DashboardButtonsWidget(
                                title: dashboardButtons[index].text,
                                imagePath: dashboardButtons[index].imagePath,
                                onPressed: () {
                                  dashboardButtons[index].onPressed();
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
