import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/providers.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/liquid_app_bar.dart';
import '../../widgets/liquid_text_field.dart';
import '../../widgets/liquid_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text;
    if (user.isEmpty || pass.isEmpty) return;
    final ok = await ref.read(authProvider.notifier).login(user, pass);
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: LiquidAppBar(
        title: '登录',
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LiquidBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0A84FF), Color(0xFFBF5AF2)],
                    ),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF0A84FF).withOpacity(0.4),
                          blurRadius: 30, spreadRadius: 8),
                    ],
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 42),
                ),
                const SizedBox(height: 16),
                const Text('欢迎回来',
                    style: TextStyle(color: Colors.white, fontSize: 26,
                        fontWeight: FontWeight.w700, letterSpacing: -0.5)),
                const SizedBox(height: 6),
                Text('登录 MT论坛账号',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15)),
                const SizedBox(height: 40),
                LiquidGlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      LiquidTextField(
                        controller: _userCtrl,
                        hint: '用户名 / 邮箱',
                        prefixIcon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          LiquidTextField(
                            controller: _passCtrl,
                            hint: '密码',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscure,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => setState(() => _obscure = !_obscure),
                              child: Icon(
                                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: Colors.white38, size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (auth.error != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF375F).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFF375F).withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: Color(0xFFFF375F), size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(auth.error!,
                                    style: const TextStyle(color: Color(0xFFFF375F), fontSize: 13)),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: LiquidButton(
                          label: '登录',
                          icon: Icons.login_rounded,
                          loading: auth.loading,
                          onPressed: _login,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {},
                  child: Text('没有账号？去注册',
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
