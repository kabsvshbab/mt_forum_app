import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../state/providers.dart';
import '../../../core/parser/discuz_parser.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/liquid_app_bar.dart';
import '../thread/thread_page.dart';
import '../post/post_page.dart';

class ForumPage extends ConsumerStatefulWidget {
  final Forum forum;
  const ForumPage({super.key, required this.forum});

  @override
  ConsumerState<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends ConsumerState<ForumPage> {
  int _page = 1;
  final List<ThreadPost> _threads = [];
  bool _loading = false;
  bool _hasMore = true;
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _load();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200 && !_loading && _hasMore) {
        _load();
      }
    });
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final list = await ref.read(threadsProvider((fid: widget.forum.fid, page: _page)).future);
      setState(() {
        if (list.isEmpty) {
          _hasMore = false;
        } else {
          _threads.addAll(list);
          _page++;
        }
      });
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
      _threads.clear();
      _hasMore = true;
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: LiquidAppBar(
        title: widget.forum.name,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.white70),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => PostPage(fid: widget.forum.fid, forumName: widget.forum.name))),
          ),
        ],
      ),
      body: LiquidBackground(
        child: SafeArea(
          child: RefreshIndicator(
            color: const Color(0xFF0A84FF),
            backgroundColor: const Color(0xFF141433),
            onRefresh: _refresh,
            child: _threads.isEmpty && _loading
                ? const _ThreadShimmer()
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: _threads.length + (_loading ? 1 : 0),
                    itemBuilder: (_, i) {
                      if (i == _threads.length) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator(color: Color(0xFF0A84FF), strokeWidth: 2)),
                        );
                      }
                      final t = _threads[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LiquidGlassCard(
                          radius: 22,
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => ThreadPage(thread: t, fid: widget.forum.fid))),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (t.isSticky)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF375F).withOpacity(0.25),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFFFF375F).withOpacity(0.5)),
                                      ),
                                      child: const Text('置顶',
                                          style: TextStyle(color: Color(0xFFFF375F), fontSize: 10, fontWeight: FontWeight.w600)),
                                    ),
                                  if (t.typeLabel != null)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0A84FF).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(t.typeLabel!,
                                          style: const TextStyle(color: Color(0xFF0A84FF), fontSize: 10)),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(t.title,
                                  style: const TextStyle(color: Colors.white,
                                      fontWeight: FontWeight.w600, fontSize: 15, height: 1.4),
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: const Color(0xFFBF5AF2).withOpacity(0.4),
                                    child: Text(t.author.isNotEmpty ? t.author[0].toUpperCase() : '?',
                                        style: const TextStyle(color: Colors.white, fontSize: 10)),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(t.author, style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12)),
                                  const Spacer(),
                                  Icon(Icons.chat_bubble_outline_rounded, color: Colors.white.withOpacity(0.35), size: 14),
                                  const SizedBox(width: 4),
                                  Text('${t.replies}', style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12)),
                                  const SizedBox(width: 12),
                                  Icon(Icons.visibility_outlined, color: Colors.white.withOpacity(0.35), size: 14),
                                  const SizedBox(width: 4),
                                  Text('${t.views}', style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _ThreadShimmer extends StatelessWidget {
  const _ThreadShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: 8,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Shimmer.fromColors(
          baseColor: Colors.white.withOpacity(0.05),
          highlightColor: Colors.white.withOpacity(0.12),
          child: Container(
            height: 100,
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
