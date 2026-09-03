import 'package:cryptocore/ui/pre_login_consent_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'signup_screen.dart';
import 'package:cryptocore/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  late AnimationController _controller;
  final Random random = Random();
  final int numberOfParticles = 40;
  final List<Offset> particles = [];
  bool _isPasswordObscured = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    for (int i = 0; i < numberOfParticles; i++) {
      particles.add(Offset(random.nextDouble(), random.nextDouble()));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSystemToast("Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmail(email: email, password: password);
      if (!mounted) return;

      // Directly navigate to PreLoginConsentScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PreLoginConsentScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Authentication failed";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email.";
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = "Invalid email or password.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address format.";
      } else if (e.code == 'user-disabled') {
        errorMessage = "This user account has been disabled.";
      }

      _showSystemToast(errorMessage);
    } catch (_) {
      _showSystemToast("An unexpected error occurred");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Displays a compact, floating system toast with Flutter Logo and high contrast styling
  void _showSystemToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 6,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black,
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.white24, width: 0.8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const FlutterLogo(size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: ParticlePainter(particles, _controller.value),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Header: Title centered at top
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),

                      // Input Fields
                      Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              labelText: "Email",
                              labelStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.35),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.white38,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _passwordController,
                            obscureText: _isPasswordObscured,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordObscured
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                                onPressed: () {
                                  if (!mounted) return;
                                  setState(() {
                                    _isPasswordObscured = !_isPasswordObscured;
                                  });
                                },
                              ),
                              labelText: "Password",
                              labelStyle: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13,
                              ),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.35),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Colors.white38,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Navigation to Sign Up
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignUpScreen(),
                                ),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 16,
                                ),
                                children: const [
                                  TextSpan(
                                    text: "Sign Up",
                                    style: TextStyle(
                                      color: Colors.cyanAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Action Button & Support Email
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 160,
                              height: 40,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blueAccent.shade400,
                                      Colors.cyanAccent.shade400,
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyanAccent.withOpacity(0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  onPressed: _isLoading ? null : _login,
                                  child: _isLoading
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF0F172A),
                                    ),
                                  )
                                      : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.login_rounded,
                                        color: Color(0xFF0F172A),
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Login",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                          letterSpacing: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Support Email Displayed Below Login Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.support_agent_outlined,
                                  color: Colors.grey.shade500,
                                  size: 15,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Support: cryptocore828@gmail.com",
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Offset> particles;
  final double progress;

  ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.cyanAccent.withOpacity(0.25);

    for (var p in particles) {
      final Offset position = Offset(
        (p.dx + progress * 0.5) % 1 * size.width,
        (p.dy + progress) % 1 * size.height,
      );
      canvas.drawCircle(position, 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}