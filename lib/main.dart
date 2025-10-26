import 'package:flutter/material.dart';
import 'ui/welcome_page.dart';

void main() {
  runApp(const SecureWipeApp());
}

class SecureWipeApp extends StatelessWidget {
  const SecureWipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Wipe',
      theme: ThemeData.dark(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const WelcomePage(),
    );
  }
}
