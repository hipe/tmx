import 'package:flutter/material.dart';
import 'posts/posts.dart';
import 'timer/timer.dart';
import 'counter/counter.dart';

class InfiniteListApp extends MaterialApp {
  const InfiniteListApp({super.key}) : super(home: const PostsPageXX());
}

class TimerApp extends StatelessWidget {
  const TimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Timer',
      theme: ThemeData(
        primaryColor: const Color.fromRGBO(109, 234, 255, 1),
        colorScheme: const ColorScheme.light(
          secondary: Color.fromRGBO(72, 74, 126, 1),
        ),
      ),
      home: const TimerPage(),
    );
  }
}

class CounterApp extends MaterialApp {
  const CounterApp({super.key}) : super(home: const CounterPage());
}
/*
# #born
*/
