import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../state/providers.dart';
import '../../../core/api/discuz_endpoints.dart';
import '../../widgets/liquid_background.dart';
import '../../widgets/liquid_glass_card.dart';
import '../../widgets/liquid_app_bar.dart';
import '../../widgets/liquid_text_field.dart';
import '../../widgets/liquid_button.dart';
import '../login/login_page.dart';

class PostPage extends ConsumerStatefulWidget {
  final int fid;
  final String forumName;
  const PostPage({super.key, required this.fid, required this.forumName});

  @override
  ConsumerState<PostPage> createState() => _PostPageState();
}

class _PostPageState extends ConsumerState<PostPage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    final box = Hive.box('drafts');
    final draft = box.get('draft_${widget.fid}');
    if (draft != null) {
      _titleCtrl.text = draft['title'] ?? '';
      _contentCtrl.text = draft['content'] ?? '';
    }
  }

  Future<void> _saveDraft() async {
    final box = Hive.box('drafts');
    await box.put('draft_${widget.fid}', {
      'title': _titleCtrl.text,
      'content': _contentCtrl.text,
    });
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) {
      setState(() => _error = '标题和内容不能为空');
      return;
    }
    final auth = ref.read(authProvider);
    if (!auth.isLoggedIn) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }
    setState(() { _submitting = true; _error = null; });
    try {
      final client = await ref.read(clientProvider.future);
      final formhash = await client.fetchFormHash();
      final resp = await client.dio.post(
        DiscuzEndpoints.newThreadSubmit(widget.fid),
        data: {
          'formhash': formhash,
          'subject': title,
          'message': content,
          'typeid': '0',
          'topicsubmit': 'yes',
          'usesig': '1',
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final html = resp.data.toString();
      if (html.contains('发布成功') || html.contains('succeedhandle') || html.contains('tid=')) {
        await Hive.box('drafts').delete('draft_${widget.fid}');
        if (mounted) Navigator.pop(context);
      } else {
        setState(() => _error = '发布失败，请稍后重试');
      }
    } catch (e) {
      setState(() => _error = '网络错误：$e');
    }
    setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: LiquidAppBar(
        title: '发帖 · ${widget.forumName}',
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white70),
          onPressed: () { _saveDraft(); Navigator.pop(context); },
        ),
      ),
      body: LiquidBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            child: Column(
              children: [
                LiquidGlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('发布到 ${widget.forumName}',
                          style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13)),
                      const SizedBox(height: 14),
                      LiquidTextField(
                        controller: _titleCtrl,
                        hint: '标题',
                        prefixIcon: Icons.title_rounded,
                      ),
                      const SizedBox(height: 14),
                      LiquidTextField(
                        controller: _contentCtrl,
                        hint: '内容（支持 BBCode）',
                        prefixIcon: Icons.edit_note_rounded,
                        maxLines: 10,
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(_error!,
                            style: const TextStyle(color: Color(0xFFFF375F), fontSize: 13)),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: LiquidButton(
                          label: '发布帖子',
                          icon: Icons.send_rounded,
                          loading: _submitting,
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
