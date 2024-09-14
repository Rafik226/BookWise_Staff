import 'package:bookwise_staff/models/librarian_model.dart';
import 'package:bookwise_staff/models/request_model.dart';
import 'package:bookwise_staff/models/book_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UnreturnedBooksPage extends StatefulWidget {
  const UnreturnedBooksPage({super.key});

  @override
  State<UnreturnedBooksPage> createState() => _UnreturnedBooksPageState();
}

class _UnreturnedBooksPageState extends State<UnreturnedBooksPage> {
  bool isLoading = false;
  List<RequestModel> unreturnedRequests = [];
  List<RequestModel> dueSoonRequests =
      []; // Liste pour les livres à rendre bientôt
  String? libraryName;

  @override
  void initState() {
    super.initState();
    fetchLibraryName();
  }

  Future<void> fetchLibraryName() async {
    setState(() {
      isLoading = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('staff')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          final staffModel = StaffModel.fromMap(doc.data()!);
          libraryName = staffModel.libraryName;
          fetchUnreturnedRequests();
          fetchDueSoonRequests(); // Appeler la fonction pour récupérer les demandes avec deux jours restants
        }
      } else {
        print("Aucun utilisateur connecté.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Erreur lors de la récupération du nom de la bibliothèque : $e");
    }
  }

  // Fonction pour récupérer les emprunts dont la date de retour est proche (dans 2 jours)
  Future<void> fetchDueSoonRequests() async {
    if (libraryName == null) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot requestSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('returnStatus', isEqualTo: 'approved') // Emprunt approuvé
          .get();

      List<RequestModel> filteredRequests = [];

      for (var doc in requestSnapshot.docs) {
        RequestModel request =
            RequestModel.fromMap(doc.data() as Map<String, dynamic>);

        // Calculer la différence de jours entre aujourd'hui et la date due
        DateTime dueDate = (request.dueDate as Timestamp).toDate();
        int daysLeft = dueDate.difference(DateTime.now()).inDays;

        if (daysLeft <= 2) {
          // Si le livre doit être rendu dans 2 jours ou moins
          filteredRequests.add(request);
        }
      }

      setState(() {
        dueSoonRequests = filteredRequests;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print(
          'Erreur lors de la récupération des emprunts à rendre bientôt : $e');
    }
  }

  // Fonction pour récupérer les demandes d'emprunt non retournées pour la bibliothèque du staff connecté
  Future<void> fetchUnreturnedRequests() async {
    if (libraryName == null) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot requestSnapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('returnStatus',
              isEqualTo: 'pending_return') // Seulement les livres non retournés
          .get();

      List<RequestModel> filteredRequests = [];

      for (var doc in requestSnapshot.docs) {
        RequestModel request =
            RequestModel.fromMap(doc.data() as Map<String, dynamic>);

        // Récupérer le livre associé à chaque demande
        DocumentSnapshot bookDoc = await FirebaseFirestore.instance
            .collection('books')
            .doc(request.bookId)
            .get();

        if (bookDoc.exists) {
          BookModel book =
              BookModel.fromMap(bookDoc.data() as Map<String, dynamic>);

          // Vérifier si le libraryName du livre correspond à celui du staff
          if (book.libraryName == libraryName) {
            filteredRequests.add(request);
          }
        }
      }

      setState(() {
        unreturnedRequests = filteredRequests;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Erreur lors de la récupération des emprunts non retournés : $e');
    }
  }

  Future<void> approveReturn(String requestId, String bookId) async {
    try {
      // Mettre à jour le statut de retour de la demande
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        'returnStatus': 'returned',
      });

      // Récupérer le livre correspondant à l'ID
      DocumentSnapshot bookDoc = await FirebaseFirestore.instance
          .collection('books')
          .doc(bookId)
          .get();

      if (bookDoc.exists) {
        // Incrémenter le champ 'available' du livre
        int currentAvailable = bookDoc['available'];
        await FirebaseFirestore.instance
            .collection('books')
            .doc(bookId)
            .update({
          'available': currentAvailable + 1,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Retour approuvé et disponibilité mise à jour')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Livre non trouvé')),
        );
      }

      // Mise à jour de la liste après l'approbation
      fetchUnreturnedRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'approbation : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Livres non retournés'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Section pour les emprunts à rendre bientôt
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Emprunts à rendre bientôt (moins de 2 jours)',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  dueSoonRequests.isEmpty
                      ? const Center(
                          child: Text('Aucun emprunt à rendre bientôt'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dueSoonRequests.length,
                          itemBuilder: (context, index) {
                            final request = dueSoonRequests[index];

                            return Card(
                              margin: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 4,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(10),
                                title: Text('Livre ID : ${request.bookId}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Text(
                                        'Nom du membre : ${request.memberName}'),
                                    Text(
                                        'INE du membre : ${request.memberIne}'),
                                    const SizedBox(height: 10),
                                    Text(
                                        'Date limite de retour : ${request.dueDate}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                  // Section pour approuver les retours en attente
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Demandes de retour en attente',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  unreturnedRequests.isEmpty
                      ? const Center(
                          child: Text('Aucune demande de retour en attente'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: unreturnedRequests.length,
                          itemBuilder: (context, index) {
                            final request = unreturnedRequests[index];

                            return Card(
                              margin: const EdgeInsets.all(10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 4,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(10),
                                title: Text('Livre ID : ${request.bookId}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Text(
                                        'Nom du membre : ${request.memberName}'),
                                    Text(
                                        'INE du membre : ${request.memberIne}'),
                                    const SizedBox(height: 10),
                                    Text(
                                        'Statut : ${request.returnStatus == "pending_return" ? "En attente de retour" : "Autre"}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.check,
                                          color: Colors.green),
                                      onPressed: () {
                                        approveReturn(
                                            request.requestId, request.bookId);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
