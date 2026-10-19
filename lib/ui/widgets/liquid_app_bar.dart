import 'dart:ui';
import 'package:flutter/material.dart';

/// 液态玻璃 AppBar（顶部玻璃条）
class LiquidAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const LiquidAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.10),
                Colors.white.withOpacity(0.02),
              ],
            ),
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.12), width: 0.5),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: kToolbarHeight,
              child: NavigationToolbar(
                leading: leading,
                middle: Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        letterSpacing: -0.3)),
                trailing: actions != null
                    ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
                    : null,
                centerMiddle: centerTitle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}