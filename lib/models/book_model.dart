import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String bookImage;
  final String libraryName;
  final String bookCategory;
  final String bookDescription;
  final int bookQuantity; 
  final DateTime createdAt;

  BookModel({
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.bookImage,
    required this.libraryName,
    required this.bookCategory,
    required this.bookDescription,
    required this.bookQuantity,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'bookImage': bookImage,
      'libraryName': libraryName,
      'bookCategory': bookCategory,
      'bookDescription': bookDescription,
      'bookQuantity': bookQuantity, // Type int dans la map
      'createdAt': Timestamp.fromDate(createdAt), // Conversion DateTime vers Timestamp
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      bookId: map['bookId'] as String,
      bookTitle: map['bookTitle'] as String,
      bookAuthor: map['bookAuthor'] as String,
      bookImage: map['bookImage'] as String,
      libraryName: map['libraryName'] as String,
      bookCategory: map['bookCategory'] as String,
      bookDescription: map['bookDescription'] as String,
      bookQuantity: map['bookQuantity'] is int
          ? map['bookQuantity'] as int
          : int.tryParse(map['bookQuantity'].toString()) ?? 0, // Gestion des valeurs incorrectes
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
