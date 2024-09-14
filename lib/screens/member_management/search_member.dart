import 'package:bookwise_staff/models/member_model.dart';
import 'package:bookwise_staff/screens/member_management/upload_or_edit_member.dart';
import 'package:bookwise_staff/services/member_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MemberSearchScreen extends StatefulWidget {
  const MemberSearchScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MemberSearchScreenState createState() => _MemberSearchScreenState();
}

class _MemberSearchScreenState extends State<MemberSearchScreen> {
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
    final memberProvider = Provider.of<MemberService>(context);

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Recherche de Membres"),
        ),
        body: Column(
          children: [
            const SizedBox(height: 15.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchTextController,
                decoration: InputDecoration(
                  hintText: "Rechercher un membre...",
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
              child: StreamBuilder<List<MemberModel>>(
                stream: memberProvider.fetchMembersStream(),
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
                        "Aucun membre trouvé",
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    );
                  }

                  List<MemberModel> members = snapshot.data!;

                  if (searchTextController.text.isNotEmpty) {
                    members = memberProvider.searchMembers(
                      searchTextController.text,
                    );
                  }

                  if (members.isEmpty) {
                    return const Center(
                      child: Text(
                        "Aucun résultat obtenu",
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: members[index].profileImage != null
                            ? CircleAvatar(
                                backgroundImage:
                                    NetworkImage(members[index].profileImage!),
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                        title: Text(
                            "${members[index].firstName} ${members[index].lastName}"),
                        subtitle: Text(members[index].email),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditOrUploadMemberScreen(
                                memberId: members[index].memberId, isEditing: true,
                                
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
