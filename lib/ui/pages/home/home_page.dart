import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../state/providers.dart';
import '../../../core/parser/discuz_parser.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/liquid_app_bar.dart';
import '../forum/forum_page.dart';
import '../thread/thread_page.dart';
import '../login/login_page.dart';
import '../profile/profile_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authProvider.notifier).init());
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: LiquidAppBar(
        title: 'MT论坛',
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white70),
            onPressed: () {},
          ),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => auth.isLoggedIn ? const ProfilePage() : const LoginPage())),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF0A84FF).withOpacity(0.6),
                child: Icon(
                  auth.isLoggedIn ? Icons.person_rounded : Icons.person_outline_rounded,
                  color: Colors.white, size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
      body: LiquidBackground(
        child: SafeArea(
          child: _selectedTab == 0 ? const _ForumTab() : const _HotTab(),
        ),
      ),
      bottomNavigationBar: _LiquidBottomNav(
        selected: _selectedTab,
        onChanged: (i) => setState(() => _selectedTab = i),
      ),
    );
  }
}

class _ForumTab extends ConsumerWidget {
  const _ForumTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forumsAsync = ref.watch(forumsProvider);
    return RefreshIndicator(
      color: const Color(0xFF0A84FF),
      backgroundColor: const Color(0xFF141433),
      onRefresh: () => ref.refresh(forumsProvider.future),
      child: forumsAsync.when(
        loading: () => const _ShimmerList(),
        error: (e, _) => _ErrorView(message: e.toString(), onRetry: () => ref.refresh(forumsProvider)),
        data: (forums) => forums.isEmpty ? _EmptyForums() : _ForumsList(forums: forums),
      ),
    );
  }
}

class _ForumsList extends StatelessWidget {
  final List<Forum> forums;
  const _ForumsList({required this.forums});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: forums.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: LiquidGlassCard(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => ForumPage(forum: forums[i]))),
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0A84FF).withOpacity(0.5),
                      const Color(0xFFBF5AF2).withOpacity(0.3),
                    ],
                  ),
                ),
                child: const Icon(Icons.forum_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(forums[i].name,
                        style: const TextStyle(color: Colors.white,
                            fontWeight: FontWeight.w600, fontSize: 16)),
                    if (forums[i].description.isNotEmpty)
                      Text(forums[i].description,
                          style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${forums[i].todayPosts}',
                      style: const TextStyle(color: Color(0xFF0A84FF),
                          fontWeight: FontWeight.w700, fontSize: 18)),
                  Text('今日',
                      style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12)),
                ],
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HotTab extends ConsumerWidget {
  const _HotTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Text('热门帖子\n（敬请期待）',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 16, height: 1.8)),
    );
  }
}

class _LiquidBottomNav extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  const _LiquidBottomNav({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: const ColorFilter.mode(Colors.transparent, BlendMode.srcOver) as dynamic,
          child: Row(
            children: [
              _NavItem(icon: Icons.forum_rounded, label: '版块', selected: selected == 0, onTap: () => onChanged(0)),
              _NavItem(icon: Icons.local_fire_department_rounded, label: '热门', selected: selected == 1, onTap: () => onChanged(1)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: selected ? const Color(0xFF0A84FF).withOpacity(0.3) : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: selected ? const Color(0xFF0A84FF) : Colors.white38, size: 22),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(
                  color: selected ? const Color(0xFF0A84FF) : Colors.white38, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Shimmer.fromColors(
          baseColor: Colors.white.withOpacity(0.06),
          highlightColor: Colors.white.withOpacity(0.15),
          child: Container(
            height: 88,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: Colors.white.withOpacity(0.08),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white.withOpacity(0.4), size: 48),
          const SizedBox(height: 16),
          Text('加载失败\n$message', textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, height: 1.6)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF0A84FF).withOpacity(0.4),
                border: Border.all(color: const Color(0xFF0A84FF).withOpacity(0.6)),
              ),
              child: const Text('重试', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyForums extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('暂无版块数据',
          style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16)),
    );
  }
}
