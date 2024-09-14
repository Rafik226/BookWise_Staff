import 'package:cloud_firestore/cloud_firestore.dart';

class RequestModel {
  final String requestId;
  final String bookId;
  final String memberId;
  final String status;
  final String returnStatus;
  final String memberName; // Nom du membre
  final String memberIne; // INE du membre
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? dueDate;

  RequestModel({
    required this.requestId,
    required this.bookId,
    required this.memberId,
    required this.status,
    required this.returnStatus,
    required this.memberName,
    required this.memberIne,
    required this.createdAt,
    this.updatedAt,
    this.dueDate,
  });

  factory RequestModel.fromMap(Map<String, dynamic> data) {
    return RequestModel(
      requestId: data['requestId'],
      bookId: data['bookId'],
      memberId: data['memberId'],
      status: data['status'],
      returnStatus: data['returnStatus'],
      memberName: data['memberName'],
      memberIne: data['memberIne'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      dueDate: data['dueDate'] != null ? (data['dueDate'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'bookId': bookId,
      'memberId': memberId,
      'status': status,
      'returnStatus': returnStatus,
      'memberName': memberName,
      'memberIne': memberIne,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'dueDate': dueDate,
    };
  }
}
