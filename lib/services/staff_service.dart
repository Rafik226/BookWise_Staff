import 'package:bookwise_staff/models/librarian_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StaffService with ChangeNotifier {
  final List<StaffModel> _staffs = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _user = FirebaseAuth.instance.currentUser;

  //Recuperer le nom de la biblio 
  Future<String?> getLibraryName() async {
    if (_user == null) return null;

    try {
      final doc = await _firestore.collection('librarians').doc(_user!.uid).get();
      final data = doc.data();
      return data?['libraryName'] as String?;
    } catch (e) {
      return null;
    }
  }
  List<StaffModel> get getStaffs {
    return _staffs;
  }

  StaffModel? findByStaffId(String staffId) {
    if (_staffs.where((element) => element.staffId == staffId).isEmpty) {
      return null;
    }
    return _staffs.firstWhere((element) => element.staffId == staffId);
  }

  List<StaffModel> searchStaffs(String query) {
    List<StaffModel> searchList = _staffs
        .where((element) =>
            element.firstName.toLowerCase().contains(query.toLowerCase()) ||
            element.lastName.toLowerCase().contains(query.toLowerCase()) ||
            element.matricule.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return searchList;
  }

  final staffDB = FirebaseFirestore.instance.collection("staff");

  Future<List<StaffModel>> fetchStaffs() async {
    try {
      await staffDB
          .orderBy("createdAt", descending: false)
          .get()
          .then((staffSnapshot) {
        _staffs.clear();
        for (var element in staffSnapshot.docs) {
          _staffs.insert(0, StaffModel.fromMap(element.data()));
        }
      });
      notifyListeners();
      return _staffs;
    } catch (error) {
      rethrow;
    }
  }

  Stream<List<StaffModel>> fetchStaffsStream() {
    try {
      return staffDB.snapshots().map((snapshot) {
        _staffs.clear();
        for (var element in snapshot.docs) {
          _staffs.insert(0, StaffModel.fromMap(element.data()));
        }
        return _staffs;
      });
    } catch (e) {
      rethrow;
    }
  }
  // Méthode pour récupérer les informations du staff
  Future<StaffModel?> fetchStaffInfo() async {
    User? user = _auth.currentUser;

    if (user == null) {
      return null; // L'utilisateur n'est pas connecté
    }

    try {
      // Supposons que les informations du staff sont stockées dans une collection 'staff' dans Firestore
      DocumentSnapshot staffDoc = await _firestore.collection('staff').doc(user.uid).get();

      if (staffDoc.exists) {
        // Convertir les données du document en un modèle StaffModel
        return StaffModel.fromMap(staffDoc.data() as Map<String, dynamic>);
      } else {
        return null; // Aucun document trouvé pour cet utilisateur
      }
    } catch (e) {
      print('Erreur lors de la récupération des informations du staff: $e');
      return null;
    }
  }
}
