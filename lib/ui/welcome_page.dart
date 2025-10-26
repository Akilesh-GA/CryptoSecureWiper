import 'package:flutter/material.dart';
import 'dart:math';
import 'login_screen.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random random = Random();
  final int numberOfParticles = 50;
  final List<Offset> particles = [];

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat();

    // Initialize random particle positions
    for (int i = 0; i < numberOfParticles; i++) {
      particles.add(Offset(random.nextDouble(), random.nextDouble()));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final Gradient buttonGradient = LinearGradient(
      colors: [Colors.blueAccent.shade700, Colors.cyanAccent.shade400],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black87, Colors.blueGrey.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Particle layer
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: ParticlePainter(particles, _controller.value),
              );
            },
          ),

          // Foreground UI
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Shield icon with button-like gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: buttonGradient,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        Icons.shield_outlined,
                        size: size.width * 0.25,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Text(
                      "Crypto Secure Wipe",
                      style: TextStyle(
                        fontSize: size.width * 0.08,
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlueAccent,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Secured Data Wiping with Tamper-Proof Assurance – One-Click Wiping Tool",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: size.width * 0.040,
                        height: 1.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 150),
                    // Cyber-style gradient button
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: buttonGradient,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          "Get Started",
                          style: TextStyle(
                            fontSize: size.width * 0.04,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
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
    final Paint paint = Paint()..color = Colors.blueAccent.withOpacity(0.3);

    for (var p in particles) {
      final Offset position = Offset(
        (p.dx + progress) % 1 * size.width,
        (p.dy + progress) % 1 * size.height,
      );
      canvas.drawCircle(position, 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
