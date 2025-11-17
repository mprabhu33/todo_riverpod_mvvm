import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/task_viewmodel.dart';
import '../widgets/task_list.dart';
import '../widgets/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';



class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});
  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final TextEditingController _controller = TextEditingController();
  User? user;
  final logger = Logger();

  @override
  void initState() {
    super.initState();
    loginWithEmail();

  }

  Future<void> loginWithEmail() async {
    try {
      UserCredential cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: "testuser1@gmail.com",
            password: "test@123",
          );

      setState(() => user = cred.user);
    } catch (e) {
      logger.e("Login failed", error: e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text('TODO - MVVM + Riverpod')),

      body: LayoutBuilder(
        builder: (context, constraints) {
          //final isWide = constraints.maxWidth > 700;

          return Row(
            children: [
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      InputField(
                        controller: _controller,
                        hintText: 'Add task title',
                        onSubmitted: (v) async {
                          if (v.trim().isEmpty || user == null) return;
                          final vm = TaskViewModel(
                            ref.read(firestoreServiceProvider),
                          );
                          await vm.addTask(title: v.trim(), ownerId: user!.uid);
                          _controller.clear();
                        },
                      ),

                      SizedBox(height: 12),
                      Expanded(
                        child: tasksAsync.when(
                          data: (tasks) => TaskList(tasks: tasks),
                          loading: () =>
                              Center(child: CircularProgressIndicator()),
                          error: (e, st) => Center(child: Text('Error: $e')),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // if (isWide)
              //   Expanded(
              //     flex: 1,
              //     child: Center(
              //       child: Text(
              //         'Select a task to view details (wide layout)',
              //         style: TextStyle(color: Colors.red),
              //       ),
              //     ),
              //   ),
            ],
          );
        },
      ),
    );
  }
}
