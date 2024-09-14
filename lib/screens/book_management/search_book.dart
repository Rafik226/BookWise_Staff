import 'package:bookwise_staff/models/book_model.dart';
import 'package:bookwise_staff/services/book_service.dart';
import 'package:bookwise_staff/widgets/book_widget.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchBook extends StatefulWidget {
  const SearchBook({super.key});

  @override
  State<SearchBook> createState() => _SearchBookState();
}

class _SearchBookState extends State<SearchBook> {
  late TextEditingController searchTextController;

  @override
  void initState() {
    searchTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookService = Provider.of<BookService>(context);

    String? passedCategory = ModalRoute.of(context)?.settings.arguments as String?;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(passedCategory ?? "Recherche"),
        ),
        body: Column(
          children: [
            const SizedBox(height: 15.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchTextController,
                decoration: InputDecoration(
                  hintText: "Rechercher un livre...",
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        searchTextController.clear();
                        FocusScope.of(context).unfocus();
                      });
                    },
                    child: const Icon(Icons.clear, color: Colors.red),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 15.0),
            Expanded(
              child: StreamBuilder<List<BookModel>>(
                stream: bookService.fetchBooksStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Une erreur s'est produite: ${snapshot.error.toString()}",
                        style: const TextStyle(color: Colors.red, fontSize: 18),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "Aucun produit pour le moment",
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    );
                  }

                  List<BookModel> books = passedCategory == null
                      ? snapshot.data!
                      : snapshot.data!.where((book) => book.bookCategory == passedCategory).toList();

                  if (searchTextController.text.isNotEmpty) {
                    books = bookService.searchBooks(searchTextController.text);
                  }

                  if (books.isEmpty) {
                    return const Center(
                      child: Text(
                        "Aucun résultat obtenu",
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    );
                  }

                  return DynamicHeightGridView(
                    itemCount: books.length,
                    builder: (context, index) {
                      return BookWidget(bookModel: books[index]);
                    },
                    crossAxisCount: 2,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
