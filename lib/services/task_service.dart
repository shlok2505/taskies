import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class TaskService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col => _db
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .collection('tasks');

  Stream<List<Task>> watchTasks() => _col
      .orderBy('dueDate')
      .snapshots()
      .map((snap) => snap.docs.map(Task.fromDoc).toList());

  Future<void> add(Task t) => _col.add(t.toMap());

  Future<void> update(Task t) => _col.doc(t.id).update(t.toMap());

  Future<void> toggleDone(Task t) =>
      _col.doc(t.id).update({'isCompleted': !t.isCompleted});

  Future<void> delete(String id) => _col.doc(id).delete();
}
