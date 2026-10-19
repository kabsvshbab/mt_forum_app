import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../state/providers.dart';
import '../../../core/parser/discuz_parser.dart';
import '../../../core/utils/bbcode.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/liquid_app_bar.dart';
import '../../widgets/liquid_text_field.dart';
import '../../widgets/liquid_button.dart';
import '../login/login_page.dart';

class ThreadPage extends ConsumerStatefulWidget {
  final ThreadPost thread;
  final int fid;
  const ThreadPage({super.key, required this.thread, required this.fid});

  @override
  ConsumerState<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends ConsumerState<ThreadPage> {
  int _page = 1;
  final List<Post> _posts = [];
  bool _loading = false;
  bool _hasMore = true;
  final ScrollController _scroll = ScrollController();
  final TextEditingController _replyCtrl = TextEditingController();
  bool _replying = false;
  bool _showReplyBox = false;

  @override
  void initState() {
    super.initState();
    _load();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200 && !_loading && _hasMore) _load();
    });
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final list = await ref.read(postsProvider((tid: widget.thread.tid, page: _page)).future);
      setState(() {
        if (list.isEmpty) { _hasMore = false; } else { _posts.addAll(list); _page++; }
      });
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _reply() async {
    final msg = _replyCtrl.text.trim();
    if (msg.isEmpty) return;
    final auth = ref.read(authProvider);
    if (!auth.isLoggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }
    setState(() => _replying = true);
    try {
      final ok = await ref.read(replyProvider((fid: widget.fid, tid: widget.thread.tid, message: msg)).future);
      if (ok && mounted) {
        _replyCtrl.clear();
        setState(() => _showReplyBox = false);
        _refreshPosts();
      }
    } catch (_) {}
    setState(() => _replying = false);
  }

  Future<void> _refreshPosts() async {
    setState(() { _page = 1; _posts.clear(); _hasMore = true; });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: LiquidAppBar(
        title: widget.thread.title,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LiquidBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _posts.isEmpty && _loading
                    ? const _PostShimmer()
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: _posts.length + (_loading ? 1 : 0),
                        itemBuilder: (_, i) {
                          if (i == _posts.length) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(child: CircularProgressIndicator(color: Color(0xFF0A84FF), strokeWidth: 2)),
                            );
                          }
                          final p = _posts[i];
                          return _PostCard(post: p, isFirst: i == 0);
                        },
                      ),
              ),
              if (_showReplyBox)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: LiquidGlassCard(
                    radius: 22,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LiquidTextField(
                          controller: _replyCtrl,
                          hint: '写下你的回复...',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: LiquidButton(
                                label: '取消',
                                color: Colors.white38,
                                onPressed: () => setState(() => _showReplyBox = false),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: LiquidButton(
                                label: '发布回复',
                                icon: Icons.send_rounded,
                                loading: _replying,
                                onPressed: _reply,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: !_showReplyBox
          ? FloatingActionButton(
              onPressed: () => setState(() => _showReplyBox = true),
              backgroundColor: const Color(0xFF0A84FF).withOpacity(0.7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.reply_rounded, color: Colors.white),
            )
          : null,
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  final bool isFirst;
  const _PostCard({required this.post, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: LiquidGlassCard(
        radius: 22,
        tintColor: isFirst ? const Color(0xFF0A84FF) : null,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                post.authorAvatar.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: post.authorAvatar,
                          width: 40, height: 40, fit: BoxFit.cover,
                          placeholder: (_, __) => _AvatarPlaceholder(letter: post.author),
                          errorWidget: (_, __, ___) => _AvatarPlaceholder(letter: post.author),
                        ),
                      )
                    : _AvatarPlaceholder(letter: post.author),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(post.author,
                              style: const TextStyle(color: Colors.white,
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          if (isFirst) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A84FF).withOpacity(0.25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('楼主',
                                  style: TextStyle(color: Color(0xFF0A84FF), fontSize: 10, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '${post.floorNumber}楼 · ${post.postTime}',
                        style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            BBCodeRenderer(html: post.content),
          ],
        ),
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  final String letter;
  const _AvatarPlaceholder({required this.letter});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFFBF5AF2).withOpacity(0.4),
      child: Text(
        letter.isNotEmpty ? letter[0].toUpperCase() : '?',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
      ),
    );
  }
}

class _PostShimmer extends StatelessWidget {
  const _PostShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 3,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Shimmer.fromColors(
          baseColor: Colors.white.withOpacity(0.05),
          highlightColor: Colors.white.withOpacity(0.12),
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.white.withOpacity(0.07),
            ),
          ),
        ),
      ),
    );
  }
}
