import 'package:flutter/material.dart';
import 'package:todo_riverpod_mvvm/views/home_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO MVVM Riverpod',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: HomeView(),
    );
  }
}
