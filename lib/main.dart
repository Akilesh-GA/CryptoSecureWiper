import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ui/welcome_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SecureWipeApp());
}

class SecureWipeApp extends StatelessWidget {
  const SecureWipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cryptocore',
      theme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const WelcomePage(),
    );
  }
}