import 'package:bookwise_staff/models/member_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class MemberService with ChangeNotifier {
  final List<MemberModel> _members = [];

  List<MemberModel> get getMembers {
    return _members;
  }

  MemberModel? findByMemberId(String memberId) {
    if (_members.where((element) => element.memberId == memberId).isEmpty) {
      return null;
    }
    return _members.firstWhere((element) => element.memberId == memberId);
  }

  List<MemberModel> searchMembers(String query) {
    List<MemberModel> searchList = _members
        .where((element) =>
            element.firstName.toLowerCase().contains(query.toLowerCase()) ||
            element.lastName.toLowerCase().contains(query.toLowerCase()) ||
            element.INE.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return searchList;
  }

  final memberDB = FirebaseFirestore.instance.collection("members");

  Future<List<MemberModel>> fetchMembers() async {
    try {
      await memberDB
          .orderBy("createdAt", descending: false)
          .get()
          .then((membersSnapshot) {
        _members.clear();
        for (var element in membersSnapshot.docs) {
          _members.insert(0, MemberModel.fromMap(element.data()));
        }
      });
      notifyListeners();
      return _members;
    } catch (error) {
      rethrow;
    }
  }

  Stream<List<MemberModel>> fetchMembersStream() {
    try {
      return memberDB.snapshots().map((snapshot) {
        _members.clear();
        for (var element in snapshot.docs) {
          _members.insert(0, MemberModel.fromMap(element.data()));
        }
        return _members;
      });
    } catch (e) {
      rethrow;
    }
  }
}
