import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StaffModel extends ChangeNotifier {
  final String staffId;
  final String firstName;
  final String lastName;
  // ignore: non_constant_identifier_names
  final String matricule;
  final String libraryName;
  final String email;
  final String password;
  final String role;
  final String phoneNumber;
  final String? profileImage;
  final DateTime createdAt;

  StaffModel({
    required this.staffId,
    required this.firstName,
    required this.lastName,
    required this.matricule,
    required this.libraryName,
    required this.email,
    required this.password,
    required this.role,
    required this.phoneNumber,
    this.profileImage,
    required this.createdAt,
  });

  // Convert StaffModel to a Map for Firebase Firestore
  Map<String, dynamic> toMap() {
    return {
      'staffId': staffId,
      'firstName': firstName,
      'lastName': lastName,
      'matricule': matricule,
      'libraryName': libraryName,
      'email': email,
      'password': password,
      'role': role,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'createdAt': createdAt, // Utilisez `createdAt` directement
    };
  }

  // Convert Firestore Document to StaffModel
  factory StaffModel.fromMap(Map<String, dynamic> map) {
    return StaffModel(
      staffId: map['staffId'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      matricule: map['matricule'] ?? '',
      libraryName: map['libraryName'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImage: map['profileImage'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
    );
  }
}
