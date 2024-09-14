import 'package:bookwise_staff/models/book_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class BookService with ChangeNotifier {
  final List<BookModel> _books = [];

  List<BookModel> get getBooks {
    return _books;
  }

  // Méthode pour trouver un livre par son ID
  BookModel? findByBookId(String bookId) {
    return _books.firstWhereOrNull((book) => book.bookId == bookId);
  }

  // Méthode pour filtrer les livres par catégorie
  List<BookModel> findByCategory(String categoryName) {
    return _books
        .where((book) =>
            book.bookCategory.toLowerCase().contains(categoryName.toLowerCase()))
        .toList();
  }

  // Méthode pour rechercher des livres
  List<BookModel> searchBooks(String searchText) {
    return _books
        .where((book) =>
            book.bookTitle.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }

  final bookDB = FirebaseFirestore.instance.collection("books");

  // Méthode pour récupérer tous les livres depuis Firestore
  Future<void> fetchBooks() async {
    try {
      final booksSnapshot = await bookDB
          .orderBy("createdAt", descending: true)
          .get();

      _books.clear();

      for (var element in booksSnapshot.docs) {
        _books.add(BookModel.fromMap(element.data()));
      }

      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  // Méthode pour récupérer les livres en tant que flux (stream)
  Stream<List<BookModel>> fetchBooksStream() {
    return bookDB.orderBy("createdAt", descending: true).snapshots().map((snapshot) {
      _books.clear();
      for (var doc in snapshot.docs) {
        _books.add(BookModel.fromMap(doc.data()));
      }
      return _books;
    });
  }
}
