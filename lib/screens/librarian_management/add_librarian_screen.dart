import 'dart:io';
import 'package:bookwise_staff/models/librarian_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bookwise_staff/services/my_app_method.dart';
import 'package:bookwise_staff/services/loading_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class EditOrUploadLibrariansScreen extends StatefulWidget {
  const EditOrUploadLibrariansScreen({
    super.key,
    this.librarianModel,
  });

  final StaffModel? librarianModel;

  @override
  State<EditOrUploadLibrariansScreen> createState() =>
      _EditOrUploadLibrariansScreenState();
}

class _EditOrUploadLibrariansScreenState
    extends State<EditOrUploadLibrariansScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _pickedImage;
  bool isEditing = false;
  String? librarianNetworkImage;

  late TextEditingController _firstNameController,
      _lastNameController,
      // ignore: non_constant_identifier_names
      _matriculeController,
      _libraryNameController,
      _emailController,
      _passwordController,
      _phoneNumberController;

  final String _roleValue = "librarian";
  bool _isLoading = false;
  String? librarianImageUrl;

  @override
  void initState() {
    if (widget.librarianModel != null) {
      isEditing = true;
      librarianNetworkImage = widget.librarianModel!.profileImage;
    }
    _firstNameController =
        TextEditingController(text: widget.librarianModel?.firstName);
    _lastNameController =
        TextEditingController(text: widget.librarianModel?.lastName);
    _matriculeController =
        TextEditingController(text: widget.librarianModel?.matricule);
    _libraryNameController =
        TextEditingController(text: widget.librarianModel?.libraryName);

    _emailController =
        TextEditingController(text: widget.librarianModel?.email);
    _passwordController =
        TextEditingController(text: widget.librarianModel?.password);
    _phoneNumberController =
        TextEditingController(text: widget.librarianModel?.phoneNumber);

    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _matriculeController.dispose();
    _libraryNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void clearForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _matriculeController.clear();
    _libraryNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _phoneNumberController.clear();
    removePickedImage();
  }

  void removePickedImage() {
    setState(() {
      _pickedImage = null;
      librarianNetworkImage = null;
    });
  }

  Future<void> _uploadlibrarian() async {
    final isValid = _formKey.currentState!.validate();
    final FirebaseStorage storage = FirebaseStorage.instance;
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });

        // Créer un compte utilisateur Firebase Authentication
        UserCredential credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Upload de l'image sélectionnée, s'il y en a une
        if (_pickedImage != null) {
          final ref = storage
              .ref()
              .child("librariansImages")
              .child('${credential.user!.uid}.jpg');
          await ref.putFile(File(_pickedImage!.path));
          librarianImageUrl = await ref.getDownloadURL();
        }

        // Sauvegarde des données du bibliothécaire dans Firestore
        await FirebaseFirestore.instance
            .collection("staff")
            .doc(credential.user!.uid)
            .set({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'matricule': _matriculeController.text.trim(),
          'libraryName': _libraryNameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': _roleValue,
          'phoneNumber': _phoneNumberController.text.trim(),
          'profileImage': librarianImageUrl,
          'createdAt': Timestamp.now(),
        });

        Fluttertoast.showToast(
          msg: "Bibliothécaire ajouté avec succès",
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
      } on FirebaseAuthException catch (e) {
        // Gestion des erreurs lors de la création du compte
        await MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "Erreur lors de la création du compte: ${e.message}",
          fct: () {},
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

  Future<void> _editlibrarian() async {
    final isValid = _formKey.currentState!.validate();
    TextEditingController(text: widget.librarianModel?.phoneNumber);
    final FirebaseStorage storage = FirebaseStorage.instance;

    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState!.save();
      try {
        setState(() {
          _isLoading = true;
        });

        // Upload the image if a new one is selected
        if (_pickedImage != null) {
          final ref = storage
              .ref()
              .child("librariansImages")
              .child('${widget.librarianModel!.matricule}.jpg');
          await ref.putFile(File(_pickedImage!.path));
          librarianImageUrl = await ref.getDownloadURL();
        }

        // Update the librarian data in Firestore
        await FirebaseFirestore.instance
            .collection("staff")
            .doc(widget.librarianModel!.matricule)
            .update({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'matricule': widget.librarianModel!.matricule,
          'email': _emailController.text,
          'password': _passwordController.text,
          'role': _roleValue,
          'phoneNumber': _phoneNumberController.text,
          'profileImage': librarianImageUrl ?? librarianNetworkImage,
          'createdAt': widget.librarianModel!.createdAt,
        });

        Fluttertoast.showToast(
          msg: "Membre modifié avec succès",
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
          librarianNetworkImage = null;
        });
      },
      galleryFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.gallery);
        setState(() {
          librarianNetworkImage = null;
        });
      },
      removeFCT: () {
        setState(() {
          _pickedImage = null;
        });
      },
    );
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
                    icon: const Icon(Icons.clear),
                    label: const Text(
                      "Effacer",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () {
                      clearForm();
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
                        _editlibrarian();
                      } else {
                        _uploadlibrarian();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Ajouter un bibliothecaire"),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  if (isEditing && librarianNetworkImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        librarianNetworkImage!,
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
                    ),
                  ] else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Flexible(
                        child: Image.file(
                          File(_pickedImage!.path),
                          height: size.width * 0.5,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                  ],
                  if (_pickedImage != null ||
                      librarianNetworkImage != null) ...[
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
                    ),
                  ],
                  const SizedBox(height: 25),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _firstNameController,
                            key: const ValueKey('FirstName'),
                            maxLength: 80,
                            decoration: const InputDecoration(
                              hintText: 'Prénom',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le prénom';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _lastNameController,
                            key: const ValueKey('LastName'),
                            maxLength: 80,
                            decoration: const InputDecoration(
                              hintText: 'Nom de famille',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le nom de famille';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _matriculeController,
                            key: const ValueKey('matricule'),
                            maxLength: 20,
                            decoration: const InputDecoration(
                              hintText: 'matricule',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le matricule';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _libraryNameController,
                            key: const ValueKey('libraryName'),
                            maxLength: 20,
                            decoration: const InputDecoration(
                              hintText: 'Bibliothèque',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le nom de la bibliothèque';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _emailController,
                            key: const ValueKey('Email'),
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'Email',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer l\'email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _passwordController,
                            key: const ValueKey('Password'),
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: 'Mot de passe',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le mot de passe';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _phoneNumberController,
                            key: const ValueKey('PhoneNumber'),
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: 'Numéro de téléphone',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer le numéro de téléphone';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: kBottomNavigationBarHeight + 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
