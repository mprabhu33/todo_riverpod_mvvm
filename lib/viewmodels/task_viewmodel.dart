import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());

final pageSizeProvider = Provider((ref) => 20);

final tasksStreamProvider = StreamProvider.autoDispose<List<Task>>((ref) {
  final svc = ref.watch(firestoreServiceProvider);
  final pageSize = ref.watch(pageSizeProvider);
  // For demo: global stream of latest tasks (in production filter by user)
  return svc.tasksStream(limit: pageSize);
});

class TaskViewModel {
  final FirestoreService _svc;
  TaskViewModel(this._svc);

  Future<void> addTask({
    required String title,
    String description = '',
    required String ownerId,
    List<String>? sharedWith,
  }) async {
    final id = _svc.newId();
    final task = Task(
      id: id,
      title: title,
      description: description,
      ownerId: ownerId,
      sharedWith: sharedWith ?? [],
      done: false,
      updatedAt: Timestamp.now(),
    );
    // create a 'participants' compound field for easier querying (owner + sharedWith)
    final map = task.toMap();
    map['participants'] = [ownerId, ...?sharedWith];
    await _svc.createTask(task);
    await FirebaseFirestore.instance.collection('tasks').doc(id).update({'participants': map['participants'], 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> toggleDone(Task t) async {
    await _svc.updateTask(t.id, {'done': !t.done});
  }

  Future<void> update(Task t, {String? title, String? description, List<String>? sharedWith}) async {
    final changes = <String, dynamic>{};
    if (title != null) changes['title'] = title;
    if (description != null) changes['description'] = description;
    if (sharedWith != null) changes['sharedWith'] = sharedWith;
    if (sharedWith != null) changes['participants'] = [t.ownerId, ...sharedWith];
    await _svc.updateTask(t.id, changes);
  }

  Future<void> delete(String id) async {
    await _svc.deleteTask(id);
  }
}
