import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../home/home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
      vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomePage(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: Center(
        child: AnimatedBuilder(
          animation: _breath,
          builder: (_, __) {
            final scale = 1.0 + 0.05 * math.sin(_breath.value * math.pi);
            final opacity = 0.7 + 0.3 * math.sin(_breath.value * math.pi);
            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF0A84FF), Color(0xFFBF5AF2)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0A84FF).withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.forum_rounded, color: Colors.white, size: 52),
                    ),
                    const SizedBox(height: 28),
                    const Text('MT论坛',
                        style: TextStyle(color: Colors.white, fontSize: 28,
                            fontWeight: FontWeight.w700, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Text('Liquid Glass',
                        style: TextStyle(color: Colors.white.withOpacity(0.45),
                            fontSize: 14, letterSpacing: 4)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
