import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 液态玻璃背景 - 多层浮动光斑
class LiquidBackground extends StatefulWidget {
  final Widget child;
  const LiquidBackground({super.key, required this.child});

  @override
  State<LiquidBackground> createState() => _LiquidBackgroundState();
}

class _LiquidBackgroundState extends State<LiquidBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 18))..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0A1A),
            Color(0xFF141433),
            Color(0xFF0A0A1A),
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          final t = _ctrl.value * 2 * math.pi;
          return CustomPaint(
            painter: _GlowPainter(t),
            child: widget.child,
          );
        },
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  final double t;
  _GlowPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    void drawGlow(Offset center, double radius, Color color, double opacity) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [color.withOpacity(opacity), color.withOpacity(0)],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, paint);
    }

    final w = size.width, h = size.height;
    // 三个浮动光斑，缓慢移动
    drawGlow(
      Offset(w * (0.25 + 0.08 * math.sin(t * 0.7)), h * (0.18 + 0.05 * math.cos(t * 0.9))),
      w * 0.55,
      const Color(0xFF0A84FF),
      0.28,
    );
    drawGlow(
      Offset(w * (0.78 + 0.06 * math.cos(t * 0.6)), h * (0.55 + 0.07 * math.sin(t * 0.8))),
      w * 0.65,
      const Color(0xFFBF5AF2),
      0.22,
    );
    drawGlow(
      Offset(w * (0.45 + 0.07 * math.sin(t * 0.5)), h * (0.88 + 0.04 * math.cos(t * 0.7))),
      w * 0.5,
      const Color(0xFFFF375F),
      0.18,
    );
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) => oldDelegate.t != t;
}
