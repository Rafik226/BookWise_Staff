import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String memberId;
  final String firstName;
  final String lastName;
  // ignore: non_constant_identifier_names
  final String INE;
  final String email;
  final String password;  
  final String role;
  final String phoneNumber;
  final String? profileImage;  
  final DateTime createdAt;

  MemberModel({
    required this.memberId,
    required this.firstName,
    required this.lastName,
    // ignore: non_constant_identifier_names
    required this.INE,
    required this.email,
    required this.password,  
    required this.role,
    required this.phoneNumber,
    this.profileImage,  // Champ optionnel
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'firstName': firstName,
      'lastName': lastName,
      'INE': INE,
      'email': email,
      'password': password,
      'role': role,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'createdAt': Timestamp.fromDate(createdAt), // Conversion correcte du DateTime
    };
  }

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    return MemberModel(
      memberId: map['memberId'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      INE: map['INE'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? 'member',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImage: map['profileImage'] ?? 'assets/logo.png', // Valeur par défaut si null
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(), // Gestion des erreurs
    );
  }
}
