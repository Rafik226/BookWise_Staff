import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddBookCategoryScreen extends StatefulWidget {
   // ignore: prefer_const_constructors_in_immutables
   AddBookCategoryScreen({super.key});

  @override
  State<AddBookCategoryScreen> createState() => _AddBookCategoryScreenState();
}

class _AddBookCategoryScreenState extends State<AddBookCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _categoryNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  Future<void> _uploadCategory() async {
    final isValid = _formKey.currentState!.validate();

    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });

        final categoryID = FirebaseFirestore.instance.collection('categories').doc().id;

        await FirebaseFirestore.instance
            .collection("categories")
            .doc(categoryID)
            .set({
          'categoryId': categoryID,
          'categoryName': _categoryNameController.text,
          'createdAt': Timestamp.now(),
        });
        Fluttertoast.showToast(
          msg: "Catégorie ajoutée avec succès",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.white,
        );
        _categoryNameController.clear();
      } on FirebaseException catch (error) {
        Fluttertoast.showToast(
          msg: "Une erreur s'est produite: ${error.message}",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.red,
        );
      } catch (error) {
        Fluttertoast.showToast(
          msg: "Une erreur s'est produite: $error",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.red,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter une catégorie"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _categoryNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la catégorie',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom de catégorie';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _uploadCategory,
                      child: const Text("Ajouter"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
