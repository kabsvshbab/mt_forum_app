import 'dart:ui';
import 'package:flutter/material.dart';

/// 液态玻璃输入框
class LiquidTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;

  const LiquidTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.0),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.45)),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: Colors.white70, size: 22)
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }
}
