import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/providers.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/liquid_app_bar.dart';
import '../../widgets/liquid_button.dart';
import '../login/login_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: LiquidAppBar(
        title: '我的',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LiquidBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            child: Column(
              children: [
                LiquidGlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFF0A84FF).withOpacity(0.4),
                        child: Text(
                          (auth.username ?? 'M')[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white,
                              fontSize: 32, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        auth.username ?? '未登录',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        auth.isLoggedIn ? 'MT论坛会员' : '请先登录',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (auth.isLoggedIn) ...[
                  _MenuSection(items: [
                    _MenuItem(icon: Icons.article_outlined, label: '我的帖子', onTap: () {}),
                    _MenuItem(icon: Icons.bookmark_outline_rounded, label: '我的收藏', onTap: () {}),
                    _MenuItem(icon: Icons.notifications_outlined, label: '消息提醒', onTap: () {}),
                  ]),
                  const SizedBox(height: 16),
                  _MenuSection(items: [
                    _MenuItem(icon: Icons.settings_outlined, label: '设置', onTap: () {}),
                    _MenuItem(icon: Icons.info_outline_rounded, label: '关于', onTap: () {}),
                  ]),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: LiquidButton(
                      label: '退出登录',
                      icon: Icons.logout_rounded,
                      color: const Color(0xFFFF375F),
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) Navigator.pushReplacement(
                            context, MaterialPageRoute(builder: (_) => const LoginPage()));
                      },
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: LiquidButton(
                      label: '立即登录',
                      icon: Icons.login_rounded,
                      onPressed: () => Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (_) => const LoginPage())),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Icon(e.value.icon, color: Colors.white70, size: 22),
                title: Text(e.value.label,
                    style: const TextStyle(color: Colors.white, fontSize: 15)),
                trailing: Icon(Icons.chevron_right_rounded,
                    color: Colors.white.withOpacity(0.35), size: 20),
                onTap: e.value.onTap,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              ),
              if (!isLast)
                Divider(
                  height: 1, indent: 20, endIndent: 20,
                  color: Colors.white.withOpacity(0.08),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});
}
