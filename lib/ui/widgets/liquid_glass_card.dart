import 'dart:ui';
import 'package:flutter/material.dart';

/// iOS 26 液态玻璃卡片
/// - 24σ 高斯模糊
/// - 双层柔光阴影
/// - 28px 连续圆角
/// - 弹簧延迟跟随物理
class LiquidGlassCard extends StatefulWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double blurSigma;
  final Color? tintColor;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.radius = 28,
    this.padding,
    this.onTap,
    this.blurSigma = 24,
    this.tintColor,
  });

  @override
  State<LiquidGlassCard> createState() => _LiquidGlassCardState();
}

class _LiquidGlassCardState extends State<LiquidGlassCard>
    with SingleTickerProviderStateMixin {
  Offset _drag = Offset.zero;
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700));
  late Animation<Offset> _anim;

  @override
  void initState() {
    super.initState();
    _anim = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_ctrl);
    _ctrl.addListener(() => setState(() => _drag = _anim.value));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails d) =>
      setState(() => _drag = Offset(_drag.dx + d.delta.dx * 0.3, _drag.dy + d.delta.dy * 0.3));

  void _onPanEnd(_) {
    // 延迟跟随弹簧回弹
    _anim = Tween<Offset>(begin: _drag, end: Offset.zero).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Transform.translate(
        offset: _drag * 0.18,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: widget.blurSigma, sigmaY: widget.blurSigma),
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    (widget.tintColor ?? Colors.white).withOpacity(0.18),
                    (widget.tintColor ?? Colors.white).withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.32),
                  width: 1.2,
                ),
                borderRadius: BorderRadius.circular(widget.radius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.12),
                    blurRadius: 32,
                    offset: const Offset(-8, -8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.22),
                    blurRadius: 32,
                    offset: const Offset(8, 8),
                  ),
                ],
              ),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
