import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'login_screen.dart';
import 'package:cryptocore/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  final AuthService _authService = AuthService();

  late AnimationController _controller;
  final Random random = Random();
  final int numberOfParticles = 40;
  final List<Offset> particles = [];
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSystemToast("Please fill in all fields");
      return;
    }

    if (password != confirmPassword) {
      _showSystemToast("Passwords do not match");
      return;
    }

    if (password.length < 6) {
      _showSystemToast("Password must be at least 6 characters");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signUpWithEmail(email: email, password: password);
      if (!mounted) return;

      _showSystemToast("Account created successfully!");

      // Navigate to login screen after successful signup
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      });
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Sign up failed";
      if (e.code == 'email-already-in-use') {
        errorMessage = "An account already exists for this email.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address format.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password provided is too weak.";
      }

      _showSystemToast(errorMessage);
    } catch (_) {
      _showSystemToast("An unexpected error occurred");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Displays system default styled toast (White BG, Black text, App Logo)
  void _showSystemToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 4,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.fixed,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.security_rounded,
                color: Colors.cyanAccent,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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
                      // Header
                      const Row(
                        children: [
                          Text(
                            "Create Account",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),

                      // Input Fields
                      Column(
                        children: [
                          // Username Field
                          TextField(
                            controller: _usernameController,
                            keyboardType: TextInputType.name,
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
                                Icons.person_outline_rounded,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              labelText: "Username",
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

                          // Email Field
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
                          const SizedBox(height: 16),

                          // Password Field
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

                          // Confirm Password Field
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _isConfirmPasswordObscured,
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
                                  _isConfirmPasswordObscured
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey.shade400,
                                  size: 20,
                                ),
                                onPressed: () {
                                  if (!mounted) return;
                                  setState(() {
                                    _isConfirmPasswordObscured =
                                    !_isConfirmPasswordObscured;
                                  });
                                },
                              ),
                              labelText: "Confirm Password",
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

                          // Toggle link to Login
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 16,
                                ),
                                children: const [
                                  TextSpan(
                                    text: "Login",
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

                      // Action Button
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: SizedBox(
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
                              onPressed: _isLoading ? null : _signUp,
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
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person_add_alt_1_rounded,
                                    color: Color(0xFF0F172A),
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Sign Up",
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