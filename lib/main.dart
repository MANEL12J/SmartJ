import 'package:flutter/material.dart';
import 'widgets/app_initializer.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Concours Équestres',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const AppInitializer(),
      routes: {
        '/login': (context) => const LoginScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
