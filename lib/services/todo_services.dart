import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo_model.dart';

class TodoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _userTodos {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be logged in');
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('todos');
  }

  Future<void> createTodo({
    required String title,
    required String description,
    required String label,
    DateTime? deadlineDate,
    required String deadlineTime,
    required String status,
  }) async {
    await _userTodos.add({
      'title': title.trim(),
      'description': description.trim(),
      'label': label,
      'deadlineDate':
      deadlineDate != null ? Timestamp.fromDate(deadlineDate) : null,
      'deadlineTime': deadlineTime,
      'status': status.toLowerCase(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTodo(
      String todoId,
      Map<String, dynamic> data,
      ) async {
    await _userTodos.doc(todoId).update(data);
  }

  Future<void> updateStatus(
      String todoId,
      String newStatus,
      ) async {
    await _userTodos.doc(todoId).update({
      'status': newStatus.toLowerCase(),
    });
  }

  Future<void> deleteTodo(String todoId) async {
    await _userTodos.doc(todoId).delete();
  }

  Stream<List<Todo>> getTodosByStatus(String status) {
    return _userTodos
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final now = DateTime.now();
      final batch = _db.batch();

      final List<Todo> todos = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final todo = Todo.fromMap(data, doc.id);

        // AUTO PINDAH KE MISSED
        if (todo.status == 'ongoing' &&
            todo.deadlineDate != null &&
            todo.deadlineDate!.isBefore(now)) {
          batch.update(doc.reference, {'status': 'missed'});
        }

        todos.add(todo);
      }

      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
      }

      // FILTER DI CLIENT (ANTI FLICKER)
      return todos.where((t) => t.status == status).toList();
    });
  }

  Stream<List<Todo>> getAllTodos() {
    return _userTodos
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Todo.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<Todo?> getTodoById(String todoId) async {
    final doc = await _userTodos.doc(todoId).get();

    if (!doc.exists || doc.data() == null) return null;

    return Todo.fromMap(doc.data()!, doc.id);
  }
}
