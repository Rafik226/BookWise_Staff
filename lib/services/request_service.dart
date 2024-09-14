import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:bookwise_staff/models/request_model.dart';

class RequestService with ChangeNotifier {
  final List<RequestModel> _requests = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<RequestModel> get getRequests {
    return _requests;
  }

  RequestModel? findByRequestId(String requestId) {
    return _requests.firstWhereOrNull((element) => element.requestId == requestId);
  }

  Future<List<RequestModel>> fetchRequests() async {
    try {
      await _firestore.collection('requests')
          .orderBy('createdAt', descending: true)
          .get()
          .then((snapshot) {
        _requests.clear();
        for (var doc in snapshot.docs) {
          _requests.add(RequestModel.fromMap(doc.data()));
        }
      });
      notifyListeners();
      return _requests;
    } catch (error) {
      rethrow;
    }
  }

  Stream<List<RequestModel>> fetchRequestsStream() {
    try {
      return _firestore.collection('requests').snapshots().map((snapshot) {
        _requests.clear();
        for (var doc in snapshot.docs) {
          _requests.add(RequestModel.fromMap(doc.data()));
        }
        return _requests;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await _firestore.collection('requests').doc(requestId).update({
        'status': status,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }
}
