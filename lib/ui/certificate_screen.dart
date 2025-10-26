import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:ui' as ui;

class CertificateScreen extends StatefulWidget {
  final String target;
  final Map<String, String> userDetails;
  final bool isSimulation;
  final String senderEmail;   // Gmail account
  final String appPassword;   // Gmail App Password

  const CertificateScreen({
    super.key,
    required this.target,
    required this.userDetails,
    required this.senderEmail,
    required this.appPassword,
    this.isSimulation = false,
  });

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final GlobalKey _certificateKey = GlobalKey();
  bool sending = false;

  /// Capture certificate as PNG and send via email
  Future<void> _sendEmail() async {
    try {
      setState(() => sending = true);

      // 1️⃣ Capture certificate widget as image
      RenderRepaintBoundary boundary =
      _certificateKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // 2️⃣ Save image temporarily
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/certificate.png');
      await file.writeAsBytes(pngBytes);

      // 3️⃣ Send email using EmailService
      await EmailService.sendEmailWithAttachment(
        recipientEmail: widget.userDetails['email']!,
        file: file,
        subject: "Cryptocore - Secure Wipe Certificate",
        body:
        "Dear ${widget.userDetails['name']},\n\nPlease find attached your certificate of ${widget.isSimulation ? 'simulated' : 'actual'} secure wipe for ${widget.target} storage.\n\nDevice: ${widget.userDetails['device']}\n\nRegards,\nSecure Wipe App",
        senderEmail: widget.senderEmail,
        appPassword: widget.appPassword,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Certificate sent via email successfully!")),
      );
    } catch (e) {
      print("❌ Failed to send email: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to send email: $e")),
      );
    } finally {
      setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text(widget.isSimulation
            ? "Secure Wipe Certificate"
            : "Secure Wipe Certificate"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RepaintBoundary(
              key: _certificateKey,
              child: Card(
                color: Colors.grey[850],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Certificate of Secure Data Wipe",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text("User: ${widget.userDetails['name']}",
                          style: const TextStyle(color: Colors.white70)),
                      Text("Email: ${widget.userDetails['email']}",
                          style: const TextStyle(color: Colors.white70)),
                      Text("Device: ${widget.userDetails['device']}",
                          style: const TextStyle(color: Colors.white70)),
                      Text("Target: ${widget.target} Storage",
                          style: const TextStyle(color: Colors.white70)),
                      Text(
                        widget.isSimulation
                            ? "Status: Wiping Completed ✅"
                            : "Status: Wiping Completed ✅",
                        style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold),
                      ),
                      Text("Date: ${DateTime.now()}",
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: sending ? null : _sendEmail,
                  child: sending
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : const Text("Send via Email",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EmailService {
  static Future<void> sendEmailWithAttachment({
    required String recipientEmail,
    required File file,
    required String subject,
    required String body,
    required String senderEmail,
    required String appPassword,
  }) async {
    try {
      final smtpServer = SmtpServer(
        'smtp.gmail.com',
        port: 465,
        ssl: true,
        username: senderEmail,
        password: appPassword,
      );

      final message = Message()
        ..from = Address(senderEmail, 'Secure Wipe App')
        ..recipients.add(recipientEmail)
        ..subject = subject
        ..text = body
        ..attachments = [
          FileAttachment(file)..fileName = 'certificate.png',
        ];

      final sendReport = await send(message, smtpServer);
      print('✅ Message sent: $sendReport');
    } on SocketException catch (e) {
      print('❌ Network error: $e');
      throw Exception('Network unavailable. Please check your internet connection.');
    } catch (e) {
      print('❌ Error sending email: $e');
      throw e;
    }
  }
}
