import 'package:flutter/material.dart';
import 'package:ababil_flutter/screens/home_screen.dart';

void main() {
  runApp(const AbabilApp());
}

class AbabilApp extends StatelessWidget {
  const AbabilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ababil',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
