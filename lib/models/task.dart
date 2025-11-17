import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String ownerId; // uid of owner
  final List<String> sharedWith; // list of user ids or emails
  final bool done;
  final Timestamp updatedAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.sharedWith,
    required this.done,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'ownerId': ownerId,
        'sharedWith': sharedWith,
        'done': done,
        'updatedAt': updatedAt,
      };

  factory Task.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      ownerId: data['ownerId'] ?? '',
      sharedWith: List<String>.from(data['sharedWith'] ?? []),
      done: data['done'] ?? false,
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }
}
