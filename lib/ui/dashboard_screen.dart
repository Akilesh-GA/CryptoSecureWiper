import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/storage_utils.dart';
import '../utils/sdcard_utils.dart';
import '../utils/flash_utils.dart';
import '../widgets/storage_section.dart';
import '../widgets/gradient_button.dart';
import 'certificate_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _channel = MethodChannel("com.example.securewipe/channel");

  Map<String, double>? internalStats;
  Map<String, dynamic>? sdStats;
  Map<String, double>? flashStats;
  bool loading = true;

  double _wipeProgress = 0.0;
  bool _isWiping = false;

  @override
  void initState() {
    super.initState();
    _loadStorageData();
  }

  Future<void> _loadStorageData() async {
    setState(() => loading = true);

    try {
      final internal = await StorageUtils.getStorageStats();
      final flash = await FlashUtils.getCombinedStorageStats();
      Map<String, dynamic>? sd;

      try {
        sd = await SdCardUtils.getSdCardStats();
      } catch (e) {
        sd = {"found": false};
      }

      setState(() {
        internalStats = {
          "total": internal['total'] ?? 1,
          "used": internal['used'] ?? 0,
          "free": internal['free'] ?? 0,
        };
        flashStats = flash;
        sdStats = sd ?? {"found": false};
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error loading storage data: $e")));
    }
  }

  /// ✅ Request Admin Access
  Future<void> _requestAdminAccess() async {
    try {
      final bool? result =
      await _channel.invokeMethod<bool>("enableDeviceAdmin"); // Kotlin side
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Admin Access Granted ✅")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Admin Access Denied ❌")),
        );
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error requesting admin access: ${e.message}")),
      );
    } on MissingPluginException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Admin plugin not implemented on this platform")),
      );
    }
  }

  Future<void> _wipeData(String target) async {
    if (_isWiping) return;
    final confirmed = target == "Secure" ? true : await _showConfirmationDialog(target);
    if (!confirmed) return;

    final userDetails = await _getUserDetails();
    if (userDetails == null) return;

    _isWiping = true;
    _wipeProgress = 0.0;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Secure wipe started...")),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text(
            "Secure Wipe in Progress",
            style: TextStyle(color: Colors.redAccent),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(
                value: _wipeProgress,
                color: Colors.redAccent,
                backgroundColor: Colors.white12,
              ),
              const SizedBox(height: 10),
              Text(
                "Processing... ${(_wipeProgress * 100).toStringAsFixed(1)}%",
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _isWiping = false;
                Navigator.of(context).pop();
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    try {
      // ✅ Call Kotlin UserDataWipeHelper via MethodChannel
      final result = await _channel.invokeMethod<List<dynamic>>("oneClickWipe");
      setState(() => _wipeProgress = 1.0);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result != null && result.isNotEmpty
              ? result.join("\n")
              : "Secure wipe completed successfully"),
        ),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Wipe failed: ${e.message ?? 'Unknown error'}")));
    } finally {
      _isWiping = false;
      setState(() => _wipeProgress = 0.0);
      Navigator.of(context).pop();
      _loadStorageData();
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CertificateScreen(
          target: target,
          userDetails: userDetails,
          isSimulation: false,
          senderEmail: "cryptocore828@gmail.com",
          appPassword: "bxwfsqybergrsrxi",
        ),
      ),
    );
  }

  Future<bool> _showConfirmationDialog(String target) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Confirm $target Wipe',
            style: const TextStyle(color: Colors.redAccent)),
        content: Text(
          'Are you sure you want to securely wipe $target storage? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Wipe Now')),
        ],
      ),
    ) ??
        false;
  }

  Future<Map<String, String>?> _getUserDetails() async {
    final nameController = TextEditingController();
    final deviceController = TextEditingController();
    final emailController = TextEditingController();

    return await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          "Enter User Details",
          style: TextStyle(color: Colors.lightBlueAccent),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Username",
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            TextField(
              controller: deviceController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Device Name",
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  deviceController.text.isNotEmpty &&
                  emailController.text.isNotEmpty) {
                Navigator.of(context).pop({
                  "name": nameController.text,
                  "device": deviceController.text,
                  "email": emailController.text,
                });
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF101010),
        body: Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                "Secure Wipe Dashboard",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (internalStats != null)
                      StorageSection(
                        label: "Internal Storage",
                        total: internalStats!['total']!,
                        used: internalStats!['used']!,
                        free: internalStats!['free']!,
                        color: Colors.cyanAccent,
                      )
                    else
                      const Text("No Internal Storage Data",
                          style: TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 30),
                    if (sdStats?['found'] == true && sdStats?['total'] != null)
                      StorageSection(
                        label: "SD Card Storage",
                        total: (sdStats!['total'] as double?) ?? 1.0,
                        used: (sdStats!['used'] as double?) ?? 0.0,
                        free: (sdStats!['free'] as double?) ?? 0.0,
                        color: Colors.orangeAccent,
                      )
                    else
                      const Text("No SD Card Found",
                          style: TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 30),
                    if (flashStats != null)
                      StorageSection(
                        label: "Flash Memory (Total Device Storage)",
                        total: flashStats!['total']!,
                        used: flashStats!['used']!,
                        free: flashStats!['free']!,
                        color: Colors.lightGreenAccent,
                      )
                    else
                      const Text("No Flash Memory Data",
                          style: TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: GradientButton(
                label: "Enable Admin Access",
                colors: [Colors.blueAccent, Colors.lightBlue],
                onPressed: _requestAdminAccess,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: GradientButton(
                label: "Secure Wipe",
                colors: [Colors.redAccent, Colors.red.shade700],
                onPressed: () => _wipeData("Secure"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}