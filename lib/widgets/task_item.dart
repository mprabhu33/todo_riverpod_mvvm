import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/task_viewmodel.dart';
import '../views/task_detail_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskItem extends ConsumerWidget {
  final Task task;
  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = TaskViewModel(ref.read(firestoreServiceProvider));
    return ListTile(
      title: Text(task.title),
      subtitle: Text(
        task.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      leading: Checkbox(
        value: task.done,
        onChanged: (v) async {
          await vm.toggleDone(task);
        },
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (choice) async {
          if (choice == 'share') {
            // share via native sheet
           //String taskInfo =  'Task: '+task.title+'\n\n'+task.description;
           String taskInfo = 'Task: ${task.title}\n\n${task.description}';
            SharePlus.instance.share(
              ShareParams(text: taskInfo),
            );
          } else if (choice == 'email') {
            String subject = 'Shared task: ${task.title}';
            final mailto = Uri(
              scheme: 'mailto',
              path: task.sharedWith.isNotEmpty ? task.sharedWith.first : '',
              queryParameters: {
                'subject': subject,
                'body': task.description,
              },
            );
            if (await canLaunchUrl(mailto)) {
              await launchUrl(mailto);
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cannot open email client')),
                );
              }
            }
          } else if (choice == 'edit') {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TaskDetailView(task: task)),
            );
          } else if (choice == 'delete') {
            await vm.delete(task.id);
          }
        },
        itemBuilder: (ctx) => const [
          PopupMenuItem(value: 'share', child: Text('Share')),
          PopupMenuItem(value: 'email', child: Text('Share via Email')),
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }
}
