import 'package:bookwise_staff/constant/constant.dart';
import 'package:bookwise_staff/models/librarian_model.dart';
import 'package:bookwise_staff/models/request_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  // Récupérer les requêtes (emprunts) filtrées par bibliothèque de l'utilisateur connecté
  Stream<List<RequestModel>> _fetchLibraryRequests(String libraryName) {
    return FirebaseFirestore.instance
        .collection('requests')
        .where('libraryName', isEqualTo: libraryName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return RequestModel.fromMap(doc.data());
      }).toList();
    });
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      print("Error updating request status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Constants.primaryColor,
      ),
    );
  }

  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'rejected':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
    }
  }
}

extension StringCapitalization on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
