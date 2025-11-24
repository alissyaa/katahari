import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo_model.dart';

class TodoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _todos => _db.collection('todos');

  // create
  Future<void> createTodo({
    required String title,
    required String description,
    required String label,
    DateTime? deadlineDate,
    required String deadlineTime,
    required String status,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User must be logged in");

    await _todos.add({
      'title': title,
      'description': description,
      'label': label,
      'deadlineDate':
      deadlineDate != null ? Timestamp.fromDate(deadlineDate) : null,
      'deadlineTime': deadlineTime,
      'status': status.toLowerCase(),
      'createdAt': Timestamp.now(), // Ubah dari serverTimestamp ke Timestamp.now()
      'userId': user.uid,
    });
  }

  // update
  Future<void> updateTodo(String id, Map<String, dynamic> data) async {
    await _todos.doc(id).update(data);
  }

  // ypdate status
  Future<void> updateStatus(String id, String newStatus) async {
    await _todos.doc(id).update({'status': newStatus.toLowerCase()});
  }

  // delete
  Future<void> deleteTodo(String id) async {
    await _todos.doc(id).delete();
  }

  // ambil dari status
  Stream<List<Todo>> getTodosByStatus(String status) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return _todos
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: status.toLowerCase())
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) =>
        Todo.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList());
  }

  Future<void> markMissedTodos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();

    final snap = await _todos
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'ongoing')
        .get();

    final batch = _db.batch();

    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final deadline = data['deadlineDate'] as Timestamp?;

      if (deadline != null) {
        if (deadline.toDate().isBefore(now)) {
          batch.update(doc.reference, {'status': 'missed'});
        }
      }
    }

    await batch.commit();
  }
}