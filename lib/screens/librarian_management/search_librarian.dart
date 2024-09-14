import 'package:bookwise_staff/models/librarian_model.dart';
import 'package:bookwise_staff/screens/librarian_management/add_librarian_screen.dart';
import 'package:bookwise_staff/services/staff_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StaffSearchScreen extends StatefulWidget {
  const StaffSearchScreen({super.key});

  @override
  _StaffSearchScreenState createState() => _StaffSearchScreenState();
}

class _StaffSearchScreenState extends State<StaffSearchScreen> {
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
    final staffProvider = Provider.of<StaffService>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Recherche de Bibliothécaires"),
          backgroundColor: Colors.indigo,
          elevation: 0,
        ),
        body: Column(
          children: [
            const SizedBox(height: 15.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchTextController,
                decoration: InputDecoration(
                  hintText: "Rechercher un bibliothécaire...",
                  filled: true,
                  fillColor: Colors.indigo[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        searchTextController.clear();
                        FocusScope.of(context).unfocus();
                      });
                    },
                    child: const Icon(
                      Icons.clear,
                      color: Colors.red,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 15.0),
            Expanded(
              child: StreamBuilder<List<StaffModel>>(
                stream: staffProvider.fetchStaffsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
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
                        "Aucun bibliothécaire trouvé",
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    );
                  }

                  List<StaffModel> staffs = snapshot.data!;

                  if (searchTextController.text.isNotEmpty) {
                    staffs = staffProvider.searchStaffs(
                      searchTextController.text,
                    );
                  }

                  if (staffs.isEmpty) {
                    return const Center(
                      child: Text(
                        "Aucun résultat obtenu",
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: staffs.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      color: Colors.grey,
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (context, index) {
                      final staff = staffs[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          backgroundImage: staff.profileImage != null
                              ? NetworkImage(staff.profileImage!)
                              : const AssetImage("assets/logo.png"),
                          child: staff.profileImage == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        title: Text(
                          "${staff.firstName} ${staff.lastName}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(staff.libraryName),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios,
                              color: Colors.teal),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditOrUploadLibrariansScreen(
                                  librarianModel: staffs[index],
                                ),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditOrUploadLibrariansScreen(
                                librarianModel: staffs[index],
                              ),
                            ),
                          );
                        },
                      );
                    },
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
