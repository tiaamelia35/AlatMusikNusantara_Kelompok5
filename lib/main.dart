import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/nada_theme.dart';

void main() {
  runApp(const NadaNusantaraApp());
}

class NadaNusantaraApp extends StatelessWidget {
  const NadaNusantaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nada Nusantara',
      debugShowCheckedModeBanner: false,
      theme: NadaTheme.light(),
      home: const HomeScreen(),
    );
  }
}
