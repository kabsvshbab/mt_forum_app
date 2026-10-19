import 'dart:ui';
import 'package:flutter/material.dart';

/// 液态玻璃按钮
class LiquidButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool loading;

  const LiquidButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
    this.loading = false,
  });

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTapDown: (_) => _c.reverse(),
      onTapUp: (_) {
        _c.forward();
        widget.onPressed?.call();
      },
      onTapCancel: () => _c.forward(),
      child: ScaleTransition(
        scale: _c,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.55), color.withOpacity(0.25)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.loading)
                    const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  else if (widget.icon != null)
                    Icon(widget.icon, color: Colors.white, size: 20),
                  if (widget.icon != null || widget.loading) const SizedBox(width: 10),
                  Text(widget.label,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
