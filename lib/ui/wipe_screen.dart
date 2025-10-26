import 'package:flutter/material.dart';
import '../models/wipe_log.dart';

class CertificateScreen extends StatelessWidget {
  final WipeLog log;

  const CertificateScreen(this.log, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        title: const Text("Wipe Certificate"),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Device ID: ${log.deviceId}",
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            Text("Method: ${log.method}",
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            Text("Status: ${log.status}",
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 20),
            const Text(
              "Certificate generated successfully after wipe.",
              style: TextStyle(color: Colors.cyanAccent, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
