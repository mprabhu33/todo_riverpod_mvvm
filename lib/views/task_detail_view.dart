import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/task_viewmodel.dart';
import 'package:share_plus/share_plus.dart';

class TaskDetailView extends ConsumerStatefulWidget {
  final Task task;
  const TaskDetailView({super.key, required this.task});

  @override
  ConsumerState<TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends ConsumerState<TaskDetailView> {
  late TextEditingController _title;
  late TextEditingController _desc;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task.title);
    _desc = TextEditingController(text: widget.task.description);
  }

  @override
  Widget build(BuildContext context) {
    final vm = TaskViewModel(ref.read(firestoreServiceProvider));
    return Scaffold(
      appBar: AppBar(
        title: Text('Task details'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              final shareText =
                  'Task: \${widget.task.title}\n\n\${widget.task.description}';
              SharePlus.instance.share(ShareParams(text: shareText));
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _desc,
              decoration: InputDecoration(labelText: 'Description'),
              maxLines: 4,
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await vm.update(
                  widget.task,
                  title: _title.text,
                  description: _desc.text,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Saved')));
                }
              },
              child: Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}
