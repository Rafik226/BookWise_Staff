import 'package:bookwise_staff/models/request_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Assurez-vous d'importer Firebase Auth si nécessaire

class RequestScreen extends StatefulWidget {
  const RequestScreen({Key? key}) : super(key: key);

  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  bool isLoading = false;
  String? libraryName;

  @override
  void initState() {
    super.initState();
    fetchLibraryName(); // Appel de la fonction pour récupérer le nom de la bibliothèque lors de l'initialisation
  }

  // Fonction pour récupérer le nom de la bibliothèque du staff connecté
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
          final data = doc.data()!;
          libraryName = data['libraryName'];
          setState(() {
            isLoading = false;
          });
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

  // Fonction pour obtenir les IDs des livres appartenant à la bibliothèque du bibliothécaire
  Future<List<String>> _getBookIdsForLibrary(String libraryName) async {
    var bookSnapshot = await FirebaseFirestore.instance
        .collection('books')
        .where('libraryName', isEqualTo: libraryName)
        .get();

    return bookSnapshot.docs.map((doc) => doc.id).toList();
  }

  // Fonction pour récupérer les demandes basées sur les IDs des livres de la bibliothèque
  Stream<List<RequestModel>> _fetchRequestsForLibrary(List<String> bookIds) {
    return FirebaseFirestore.instance
        .collection('requests')
        .where('bookId', whereIn: bookIds)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => RequestModel.fromMap(doc.data()))
            .toList());
  }

  Future<void> _updateRequestStatus(
      String requestId, String newStatus, String bookId) async {
    try {
      // Récupérer la demande actuelle
      var requestDoc = await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .get();

      if (requestDoc.exists) {
        var requestData = requestDoc.data()!;

        // Vérifier si la demande est déjà approuvée
        if (requestData['status'] == 'approved') {
          print("Cette demande a déjà été approuvée.");
          // Tu peux aussi afficher une notification à l'utilisateur pour lui dire que la demande est déjà approuvée
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cette demande a déjà été approuvée.")));
          return; // On arrête la fonction ici si la demande est déjà approuvée
        }

        // Si la demande n'est pas encore approuvée, continuer l'approbation
        DateTime? dueDate;
        if (newStatus == 'approved') {
          dueDate =
              DateTime.now().add(const Duration(days: 7)); // Ajout de 7 jours

          // Récupérer la quantité disponible du livre
          var bookDoc = await FirebaseFirestore.instance
              .collection('books')
              .doc(bookId)
              .get();
          if (bookDoc.exists) {
            var bookData = bookDoc.data()!;
            int available = bookData['available'];

            // Si la quantité est supérieure à zéro, la diminuer
            if (available > 0) {
              await FirebaseFirestore.instance
                  .collection('books')
                  .doc(bookId)
                  .update({
                'available':
                    available - 1, // Diminuer la quantité de livres disponibles
              });
            }
          }
        }

        // Mettre à jour la demande avec le nouveau statut et la dueDate si approuvé
        await FirebaseFirestore.instance
            .collection('requests')
            .doc(requestId)
            .update({
          'status': newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
          if (dueDate != null) 'dueDate': dueDate,
        });

        setState(() {}); // Mise à jour de l'interface utilisateur
      }
    } catch (e) {
      print("Erreur lors de la mise à jour du statut : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les demandes'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : libraryName ==
                  null // Vérification si libraryName est bien initialisé
              ? const Center(
                  child: Text(
                      'Erreur : Le nom de la bibliothèque est introuvable.'),
                )
              : FutureBuilder<List<String>>(
                  future: _getBookIdsForLibrary(libraryName!),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<String>> bookIdsSnapshot) {
                    if (bookIdsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (bookIdsSnapshot.hasError) {
                      return const Center(
                          child: Text(
                              'Erreur lors de la récupération des livres.'));
                    } else if (!bookIdsSnapshot.hasData ||
                        bookIdsSnapshot.data!.isEmpty) {
                      return const Center(
                          child: Text(
                              'Aucun livre trouvé pour cette bibliothèque.'));
                    }

                    final bookIds = bookIdsSnapshot.data!;

                    return StreamBuilder<List<RequestModel>>(
                      stream: _fetchRequestsForLibrary(bookIds),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<RequestModel>> requestSnapshot) {
                        if (requestSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (requestSnapshot.hasError) {
                          return const Center(
                              child: Text(
                                  'Erreur lors de la récupération des demandes.'));
                        } else if (!requestSnapshot.hasData ||
                            requestSnapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('Aucune demande trouvée.'));
                        }

                        List<RequestModel> requests = requestSnapshot.data!;

                        return ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: requests.length,
                          itemBuilder: (BuildContext context, int index) {
                            RequestModel request = requests[index];

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      Colors.orange.withOpacity(0.2),
                                  child: _getStatusIcon(request.status),
                                ),
                                title: Text(
                                  'Demande pour le livre ID: ${request.bookId}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    Text(
                                      'Nom du membre: ${request.memberName}', // Affichage du nom
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    Text(
                                      'INE: ${request.memberIne}', // Affichage de l'INE
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Statut: ${request.status.capitalize()}',
                                      style: TextStyle(
                                        color: _getStatusIcon(request.status)
                                            .color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Demandé le: ${DateFormat.yMMMd().format(request.createdAt)}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    if (request.updatedAt != null)
                                      Text(
                                        'Mis à jour le: ${DateFormat.yMMMd().format(request.updatedAt!)}',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    if (request.dueDate !=
                                        null) // Affichage de la date de retour si approuvé
                                      Text(
                                        'Retour prévu le: ${DateFormat.yMMMd().format(request.dueDate!)}',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (String value) {
                                    _updateRequestStatus(request.requestId,
                                        value, request.bookId);
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return ['approved', 'rejected']
                                        .map((String status) {
                                      return PopupMenuItem<String>(
                                        value: status,
                                        child: Text(status.capitalize()),
                                      );
                                    }).toList();
                                  },
                                  icon: const Icon(Icons.more_vert,
                                      color: Colors.orange),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
    );
  }

  // Fonction pour obtenir l'icône de statut en fonction du statut de la demande
  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'rejected':
        return const Icon(Icons.cancel, color: Colors.red);
      case 'pending':
      default:
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
    }
  }
}

// Extension pour mettre en majuscule la première lettre des statuts
extension StringCasingExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
