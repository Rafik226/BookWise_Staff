import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

// Génération du mot de passe
String generateRandomPassword({int length = 8}) {
  const String chars =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final Random random = Random.secure();
  return List.generate(length, (index) => chars[random.nextInt(chars.length)])
      .join();
}

// Envoi du mot de passe par email
Future<void> sendPasswordByEmail(String email, String password) async {
    // SMTP configuration pour Gmail
    String username = 'rafikcodeur@gmail.com';
    String Gpassword = 'z v b k z o w o r w a g l s z m'; 

    final smtpServer = gmail(username, Gpassword); // Utiliser Gmail pour l'envoi

  final message = Message()
    ..from = Address(username, 'BookWise Support')
    ..recipients.add(email)
    ..subject = 'Votre mot de passe pour l\'application BookWise'
    ..text = 'Voici votre mot de passe pour l\'application BookWise: $password';

  try {
    final sendReport = await send(message, smtpServer);
    print('Message envoyé: ' + sendReport.toString());
  } catch (e) {
    print('Erreur lors de l\'envoi du message: $e');
  }
}

class PickImageWidget extends StatelessWidget {
  const PickImageWidget({super.key, this.pickedImage, required this.function});
  final XFile? pickedImage;
  final Function function;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 150,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: pickedImage == null
                ? Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Text('Aucune image choisie',
                          textAlign: TextAlign.center),
                    ),
                  )
                : Image.file(
                    File(pickedImage!.path),
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Material(
            borderRadius: BorderRadius.circular(16.0),
            color: Colors.lightBlue,
            child: InkWell(
              splashColor: Colors.red,
              borderRadius: BorderRadius.circular(16.0),
              onTap: () {
                function();
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.add_a_photo,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EditOrUploadMemberScreen extends StatefulWidget {
  final String? memberId;
  final bool isEditing;

  const EditOrUploadMemberScreen(
      {Key? key, this.memberId, required this.isEditing})
      : super(key: key);

  @override
  _EditOrUploadMemberScreenState createState() =>
      _EditOrUploadMemberScreenState();
}

class _EditOrUploadMemberScreenState extends State<EditOrUploadMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _pickedImage;
  String _firstName = '';
  String _lastName = '';
  String _ine = '';
  String _email = '';
  String _password = '';
  String _phoneNumber = '';
  String _role = 'member';
  String? _profileImage;
  bool _isLoading = false;
  bool get _isEditing => widget.isEditing;

  @override
  void initState() {
    super.initState();
    if (_isEditing && widget.memberId != null) {
      _loadMemberData();
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _pickedImage = pickedImage;
      });
    }
  }

  Future<String?> _uploadImage() async {
    if (_pickedImage == null) return null;

    try {
      final file = File(_pickedImage!.path);
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('membersImages/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putFile(file);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erreur lors de l\'upload de l\'image : $e');
      return null;
    }
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      String? profileImageUrl;
      if (_pickedImage != null) {
        profileImageUrl = await _uploadImage();
      } else {
        profileImageUrl = _profileImage;
      }

      if (_isEditing &&
          widget.memberId != null &&
          widget.memberId!.isNotEmpty) {
        // Mise à jour du membre
        await FirebaseFirestore.instance
            .collection('members')
            .doc(widget.memberId)
            .update({
          'firstName': _firstName,
          'lastName': _lastName,
          'INE': _ine,
          'email': _email,
          'phoneNumber': _phoneNumber,
          'role': _role,
          'profileImage': profileImageUrl,
        });
      } else if (!_isEditing) {
        // Génération du mot de passe
        _password = generateRandomPassword();

        // Création d'un nouveau membre avec le mot de passe généré
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        // Envoi du mot de passe par email
        await sendPasswordByEmail(_email, _password);

        await FirebaseFirestore.instance
            .collection('members')
            .doc(userCredential.user?.uid)
            .set({
          'memberId':
              userCredential.user?.uid, // Utilisation de l'UID comme memberId
          'firstName': _firstName,
          'lastName': _lastName,
          'INE': _ine,
          'email': _email,
          'phoneNumber': _phoneNumber,
          'role': _role,
          'profileImage': profileImageUrl,
          'createdAt': Timestamp.now(),
        });
      } else {
        // Gérez le cas où widget.memberId est null ou vide pour éviter des erreurs
        print('ID du membre non spécifié pour la mise à jour.');
      }

      Navigator.of(context).pop();
    } catch (e) {
      print('Erreur lors de la sauvegarde des données du membre : $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMemberData() async {
    try {
      final memberData = await FirebaseFirestore.instance
          .collection('members')
          .doc(widget.memberId)
          .get();

      if (memberData.exists) {
        setState(() {
          _firstName = memberData['firstName'];
          _lastName = memberData['lastName'];
          _ine = memberData['INE'];
          _email = memberData['email'];
          _phoneNumber = memberData['phoneNumber'];
          _role = memberData['role'];
          _profileImage = memberData['profileImage'];
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des données du membre : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Modifier Membre' : 'Ajouter Membre'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    PickImageWidget(
                      pickedImage: _pickedImage,
                      function: _pickImage,
                    ),
                    TextFormField(
                      initialValue: _firstName,
                      decoration: const InputDecoration(labelText: 'Prénom'),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _firstName = value ?? '',
                      validator: (value) =>
                          value!.isEmpty ? 'Veuillez entrer un prénom' : null,
                    ),
                    TextFormField(
                      initialValue: _lastName,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _lastName = value ?? '',
                      validator: (value) =>
                          value!.isEmpty ? 'Veuillez entrer un nom' : null,
                    ),
                    TextFormField(
                      initialValue: _ine,
                      decoration: const InputDecoration(labelText: 'INE'),
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _ine = value ?? '',
                      validator: (value) =>
                          value!.isEmpty ? 'Veuillez entrer l\'INE' : null,
                    ),
                    TextFormField(
                      initialValue: _email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _email = value ?? '',
                      validator: (value) =>
                          value!.isEmpty ? 'Veuillez entrer un email' : null,
                    ),
                    TextFormField(
                      initialValue: _phoneNumber,
                      decoration: const InputDecoration(
                          labelText: 'Numéro de téléphone'),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      onSaved: (value) => _phoneNumber = value ?? '',
                      validator: (value) => value!.isEmpty
                          ? 'Veuillez entrer un numéro de téléphone'
                          : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: _role,
                      decoration: const InputDecoration(labelText: 'Rôle'),
                      items: ['member'].map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _role = value ?? 'member'),
                      onSaved: (value) => _role = value ?? 'member',
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveMember,
                      child: Text(_isEditing ? 'Modifier' : 'Ajouter'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
