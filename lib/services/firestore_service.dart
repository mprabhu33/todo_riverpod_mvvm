import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import 'package:uuid/uuid.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection = 'tasks';
  final _uuid = Uuid();

  Stream<List<Task>> tasksStream({required int limit}) {
    return _db
        .collection(collection)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Task.fromDoc(d)).toList());
  }

  Stream<List<Task>> tasksForUserStream({required String userId, required int limit}) {
    // tasks where ownerId == userId OR sharedWith contains userId
    return _db
        .collection(collection)
        .where('participants', arrayContains: userId) // participants is owner + sharedWith
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Task.fromDoc(d)).toList());
  }

  Future<void> createTask(Task task) async {
    await _db.collection(collection).doc(task.id).set(task.toMap());
  }

  Future<void> updateTask(String id, Map<String, dynamic> changes) async {
    changes['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection(collection).doc(id).update(changes);
  }

  Future<void> deleteTask(String id) async {
    await _db.collection(collection).doc(id).delete();
  }

  String newId() => _uuid.v4();
}
