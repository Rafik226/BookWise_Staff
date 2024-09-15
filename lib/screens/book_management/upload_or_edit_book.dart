import 'dart:io';
import 'package:bookwise_staff/screens/book_management/search_book.dart';
import 'package:bookwise_staff/services/my_app_method.dart';
import 'package:bookwise_staff/models/book_model.dart';
import 'package:bookwise_staff/services/loading_manager.dart';
import 'package:bookwise_staff/services/staff_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class EditOrUploadBookScreen extends StatefulWidget {
  const EditOrUploadBookScreen({
    super.key,
    this.bookModel,
  });

  final BookModel? bookModel;

  @override
  State<EditOrUploadBookScreen> createState() => _EditOrUploadBookScreenState();
}

class _EditOrUploadBookScreenState extends State<EditOrUploadBookScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _pickedImage;
  bool isEditing = false;
  String? bookNetworkImage;
  List<String> _categories = [];
  String? _selectedCategory;
  String?
      libraryName; // Utilisez cette variable pour stocker le nom de la bibliothèque
  late TextEditingController _titleController,
      _authorController,
      _descriptionController,
      _quantityController;
  bool _isLoading = false;
  String? bookImageUrl;

  @override
  void initState() {
    super.initState();

    // Initialisation des contrôleurs
    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _descriptionController = TextEditingController();
    _quantityController = TextEditingController();

    _initialize();
  }

  Future<void> _initialize() async {
    if (widget.bookModel != null) {
      setState(() {
        isEditing = true;
        bookNetworkImage = widget.bookModel!.bookImage;
        _selectedCategory = widget.bookModel!.bookCategory;
        libraryName = widget.bookModel!.libraryName;
        _titleController.text = widget.bookModel!.bookTitle;
        _authorController.text = widget.bookModel!.bookAuthor;
        _descriptionController.text = widget.bookModel!.bookDescription;
        _quantityController.text = widget.bookModel!.bookQuantity.toString();
      });
    } else {
      final staffService = StaffService();
      final fetchedLibraryName = await staffService.getLibraryName();
      setState(() {
        libraryName = fetchedLibraryName ?? 'inconnu';
      });
    }

    // Récupérer les catégories en ligne
    _fetchCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .orderBy('categoryName')
          .get();

      setState(() {
        _categories =
            snapshot.docs.map((doc) => doc['categoryName'] as String).toList();
      });
    } catch (error) {
      Fluttertoast.showToast(
        msg: "Erreur lors de la récupération des catégories: $error",
        toastLength: Toast.LENGTH_SHORT,
        textColor: Colors.red,
      );
    }
  }

  void clearForm() {
    _titleController.clear();
    _authorController.clear();
    _descriptionController.clear();
    _quantityController.clear();
    removePickedImage();
  }

  void removePickedImage() {
    setState(() {
      _pickedImage = null;
      bookNetworkImage = null;
    });
  }

  Future<void> _uploadBook() async {
    final isValid = _formKey.currentState!.validate();

    FocusScope.of(context).unfocus();
    if (_pickedImage == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Ajouter une photo du livre",
        fct: () {},
      );
      return;
    }
    if (_selectedCategory == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Catégorie vide",
        fct: () {},
      );

      return;
    }
    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });
        final bookID = const Uuid().v4();
        if (_pickedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child("booksImages")
              .child('$bookID.jpg');
          await ref.putFile(File(_pickedImage!.path));
          bookImageUrl = await ref.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection("books").doc(bookID).set({
          'bookId': bookID,
          'bookTitle': _titleController.text,
          'bookAuthor': _authorController.text,
          'bookImage': bookImageUrl,
          'libraryName': libraryName, // Utilisation directe de la variable
          'bookCategory': _selectedCategory,
          'bookDescription': _descriptionController.text,
          'bookQuantity': _quantityController.text,
          'createdAt': Timestamp.now(),
        });
        Fluttertoast.showToast(
          msg: "Livre ajouté avec succès",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.white,
        );
        if (!mounted) return;
        await MyAppMethods.showErrorORWarningDialog(
          isError: false,
          context: context,
          subtitle: "Effacer le formulaire?",
          fct: () {
            clearForm();
          },
        );
      } on FirebaseException catch (error) {
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "Une erreur s'est produite: ${error.message}",
          fct: () {},
        );
      } catch (error) {
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "Une erreur s'est produite: $error",
          fct: () {},
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _editBook() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_pickedImage == null && bookNetworkImage == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Ajouter une image s'il vous plaît",
        fct: () {},
      );
      return;
    }
    if (_selectedCategory == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Catégorie vide",
        fct: () {},
      );

      return;
    }
    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });
        if (_pickedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child("booksImages")
              .child('${widget.bookModel!.bookId}.jpg');
          await ref.putFile(File(_pickedImage!.path));
          bookImageUrl = await ref.getDownloadURL();
        }

        await FirebaseFirestore.instance
            .collection("books")
            .doc(widget.bookModel!.bookId)
            .update({
          'bookId': widget.bookModel!.bookId,
          'bookTitle': _titleController.text,
          'bookAuthor': _authorController.text,
          'bookImage': bookImageUrl ?? bookNetworkImage,
          'libraryName': libraryName,
          'bookCategory': _selectedCategory,
          'bookDescription': _descriptionController.text,
          'bookQuantity': _quantityController.text,
          'createdAt': widget.bookModel!.createdAt,
        });
        Fluttertoast.showToast(
          msg: "Livre modifié avec succès",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.white,
        );
        if (!mounted) return;
        await MyAppMethods.showErrorORWarningDialog(
          isError: false,
          context: context,
          subtitle: "Effacer le formulaire?",
          fct: () {
            clearForm();
          },
        );
      } on FirebaseException catch (error) {
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "Une erreur s'est produite: ${error.message}",
          fct: () {},
        );
      } catch (error) {
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "Une erreur s'est produite: $error",
          fct: () {},
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> localImagePicker() async {
    final ImagePicker picker = ImagePicker();
    await MyAppMethods.imagePickerDialog(
      context: context,
      cameraFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.camera);
        setState(() {
          bookNetworkImage = null;
        });
      },
      galleryFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.gallery);
        setState(() {
          bookNetworkImage = null;
        });
      },
      removeFCT: () {
        setState(() {
          _pickedImage = null;
        });
      },
    );
  }

// Fonction pour supprimer un livre de Firestore
  Future<void> deleteBook(String bookId) async {
    try {
      // Accéder à la collection des livres et supprimer le document avec l'ID spécifié
      await FirebaseFirestore.instance.collection('books').doc(bookId).delete();
      print("Livre supprimé avec succès.");
    } catch (e) {
      print("Erreur lors de la suppression du livre : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return LoadingManager(
      isLoading: _isLoading,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              "Ajouter un livre",
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  if (isEditing && bookNetworkImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        bookNetworkImage!,
                        height: size.width * 0.3,
                        alignment: Alignment.center,
                      ),
                    ),
                  ] else if (_pickedImage == null) ...[
                    SizedBox(
                      width: size.width * 0.4 + 10,
                      height: size.width * 0.4,
                      child: DottedBorder(
                        color: Colors.blue,
                        radius: const Radius.circular(12),
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Flexible(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 80,
                                  color: Colors.blue,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  localImagePicker();
                                },
                                child: const Text("Choisir l'image"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ] else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Flexible(
                        child: Image.file(
                          File(
                            _pickedImage!.path,
                          ),
                          height: size.width * 0.5,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ],
                  if (_pickedImage != null || bookNetworkImage != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            localImagePicker();
                          },
                          child: const Text("Choisir une autre image"),
                        ),
                        TextButton(
                          onPressed: () {
                            removePickedImage();
                          },
                          child: const Text(
                            "Supprimer l'image",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )
                  ],
                  const SizedBox(
                    height: 25,
                  ),
                  DropdownButton<String>(
                    hint:
                        Text(_selectedCategory ?? "Sélectionner une catégorie"),
                    value: _selectedCategory,
                    items: _categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            key: const ValueKey('Title'),
                            maxLength: 80,
                            minLines: 1,
                            maxLines: 2,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              hintText: 'Titre du livre',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un titre';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _authorController,
                            key: const ValueKey('Author'),
                            maxLength: 50,
                            minLines: 1,
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              hintText: 'Auteur du livre',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un auteur';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            key: const ValueKey('Description'),
                            controller: _descriptionController,
                            minLines: 5,
                            maxLines: 8,
                            maxLength: 1000,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Description du livre',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer une description';
                              }
                              return null;
                            },
                            onTap: () {},
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            key: const ValueKey('Quantité'),
                            decoration: const InputDecoration(
                              hintText: 'Quantité',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer une quantité';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: kBottomNavigationBarHeight + 10,
                  ),
                ],
              ),
            ),
          ),
          bottomSheet: SizedBox(
            height: kBottomNavigationBarHeight + 10,
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: widget.bookModel == null
                        ? const Icon(Icons.clear_sharp) // Icône pour "Effacer"
                        : const Icon(Icons.delete), // Icône pour "Supprimer"
                    label: widget.bookModel == null
                        ? const Text(
                            // Texte pour "Effacer"
                            "Effacer",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          )
                        : const Text(
                            // Texte pour "Supprimer"
                            "Supprimer",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                    onPressed: widget.bookModel == null
                        ? clearForm // Fonction pour "Effacer"
                        : () {
                            deleteBook(widget.bookModel!
                                .bookId); // Fonction pour "Supprimer"
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchBook()));
                          },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.upload),
                    label: Text(
                      isEditing ? "Modifier" : "Ajouter",
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () {
                      if (isEditing) {
                        _editBook();
                      } else {
                        _uploadBook();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
