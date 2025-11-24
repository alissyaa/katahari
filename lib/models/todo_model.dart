import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String id;
  final String title;
  final String description;
  final String label;
  final DateTime? deadlineDate;
  final String deadlineTime;
  final String status;
  final DateTime createdAt;
  final String userId;

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.label,
    required this.deadlineDate,
    required this.deadlineTime,
    required this.status,
    required this.createdAt,
    required this.userId,
  });

  factory Todo.fromMap(Map<String, dynamic> map, String documentId) {
    return Todo(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      label: map['label'] ?? '',
      deadlineDate: map['deadlineDate'] != null
          ? (map['deadlineDate'] as Timestamp).toDate()
          : null,
      deadlineTime: map['deadlineTime'] ?? '',
      status: map['status'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      userId: map['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'label': label,
      'deadlineDate': deadlineDate != null
          ? Timestamp.fromDate(deadlineDate!)
          : null,
      'deadlineTime': deadlineTime,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }
}
