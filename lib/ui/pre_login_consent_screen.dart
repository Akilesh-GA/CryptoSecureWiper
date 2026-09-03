import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'package:cryptocore/services/auth_service.dart';

class PreLoginConsentScreen extends StatefulWidget {
  const PreLoginConsentScreen({super.key});

  @override
  State<PreLoginConsentScreen> createState() => _PreLoginConsentScreenState();
}

class _PreLoginConsentScreenState extends State<PreLoginConsentScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _hasAcceptedTerms = false;
  bool _isProcessing = false;

  Future<void> _onConfirmAndProceed() async {
    if (!_hasAcceptedTerms) return;

    setState(() => _isProcessing = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Record user consent, email, username, and server timestamp in Firestore
        await _firestore.collection('user_consents').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email ?? '',
          'username': user.displayName ?? 'N/A',
          'acceptedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint("Error recording user consent: $e");
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _onCancelAndSignOut() async {
    try {
      await _authService.signOut();
    } catch (_) {
      await FirebaseAuth.instance.signOut();
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _onCancelAndSignOut();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1E1E1E),
          elevation: 0,
          title: const Text(
            "User Consent",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Document Paper Container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 28.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Document Title
                        const Center(
                          child: Text(
                            "SYSTEM SANITIZATION PROTOCOL",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Center(
                          child: Text(
                            "Terms of Service & Authorization Matrix",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.black26, thickness: 1),
                        const SizedBox(height: 16),

                        // Warning Notice
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "CRITICAL NOTICE: Read this document carefully before accepting. Proceeding authorizes high-privilege execution parameters across local storage arrays.",
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Document Preamble
                        const Text(
                          "Preamble & Scope",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Crypto Core Wiper operates using direct administrative hardware hooks. By acknowledging this agreement, you grant explicitly non-revocable authorization for the execution sequences defined below:",
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Section 1
                        _buildAgreementSection(
                          sectionNumber: "SECTION 1.0",
                          title: "ContentProvider Database Purge",
                          bodyPoints: [
                            "ContentResolver issues directives across all core system database tables.",
                            "Permanent deletion of local Contacts, Call Logs, and SMS database blocks.",
                            "Overwriting and truncation of SQLite WAL (Write-Ahead Logging) journal caches.",
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Section 2
                        _buildAgreementSection(
                          sectionNumber: "SECTION 2.0",
                          title: "MediaStore Media Sanitization",
                          bodyPoints: [
                            "Recursive scans executed across system internal and mounted external storage directories via MediaStore API.",
                            "Immediate unlinking and block zeroing for Images, Videos, Audio tracks, and Downloads.",
                            "Flushing of image thumbnail databases and persistent application cache trees.",
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Section 3
                        _buildAgreementSection(
                          sectionNumber: "SECTION 3.0",
                          title: "Recursive Overwrite & Hardware Wipe Trigger",
                          bodyPoints: [
                            "Execution of multi-pass pseudorandom data overwrites managed by UserDataWipeHelper.",
                            "Transmission of standard OS wiping requests via DevicePolicyManager interface.",
                            "Purging of system keystores and hardware-backed cryptographic keys.",
                          ],
                        ),
                        const SizedBox(height: 24),

                        const Divider(color: Colors.black26, thickness: 1),
                        const SizedBox(height: 12),
                        const Text(
                          "End of Document Specifications",
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Checkbox Controls
                Theme(
                  data: ThemeData(unselectedWidgetColor: Colors.white70),
                  child: CheckboxListTile(
                    activeColor: Colors.blueAccent,
                    checkColor: Colors.white,
                    value: _hasAcceptedTerms,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setState(() => _hasAcceptedTerms = val ?? false);
                    },
                    title: const Text(
                      "I have read, understood, and accept the terms of this agreement.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                const SizedBox(height: 12),

                // Footer Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: _isProcessing ? null : _onCancelAndSignOut,
                          child: const Text(
                            "Decline & Exit",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hasAcceptedTerms
                                ? Colors.blueAccent
                                : Colors.grey.shade800,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          onPressed: (_hasAcceptedTerms && !_isProcessing)
                              ? _onConfirmAndProceed
                              : null,
                          child: _isProcessing
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Text(
                            "Accept & Proceed",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementSection({
    required String sectionNumber,
    required String title,
    required List<String> bodyPoints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$sectionNumber: $title",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        ...bodyPoints.map(
              (point) => Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "• ",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Text(
                    point,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}