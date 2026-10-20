import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

/// BBCode / Discuz HTML 内容渲染器
class BBCodeRenderer extends StatelessWidget {
  final String html;
  final TextStyle? baseStyle;

  const BBCodeRenderer({super.key, required this.html, this.baseStyle});

  @override
  Widget build(BuildContext context) {
    return Html(
      data: _preprocess(html),
      style: {
        'body': Style(
          color: Colors.white.withOpacity(0.88),
          fontSize: FontSize(15),
          lineHeight: LineHeight.number(1.6),
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
        ),
        'a': Style(
          color: const Color(0xFF0A84FF),
          textDecoration: TextDecoration.none,
        ),
        'img': Style(
          width: Width(300, Unit.auto),
        ),
        'blockquote': Style(
          backgroundColor: Colors.white.withOpacity(0.06),
          border: const Border(
            left: BorderSide(color: Color(0xFF0A84FF), width: 3),
          ),
          padding: HtmlPaddings.symmetric(horizontal: 12, vertical: 8),
          margin: Margins.symmetric(vertical: 8),
        ),
        'code': Style(
          backgroundColor: Colors.white.withOpacity(0.1),
          fontFamily: 'monospace',
          padding: HtmlPaddings.symmetric(horizontal: 4, vertical: 2),
        ),
        'p': Style(
          margin: Margins.only(bottom: 6),
        ),
      },
      onLinkTap: (url, _, __) {
        // 链接点击暂不处理，可接入 url_launcher
      },
    );
  }

  /// 预处理 Discuz BBCode 转换的 HTML
  String _preprocess(String raw) {
    String s = raw;
    // 修复相对路径图片
    s = s.replaceAllMapped(
      RegExp(r'src="(?!https?://)([^"]+)"'),
      (m) => 'src="https://bbs.binmt.cc/${m.group(1)}"',
    );
    // 移除 Discuz 附件 JS 调用
    s = s.replaceAll(
        RegExp(r'<script[^>]*>.*?</script>', dotAll: true), '');
    // 移除 onclick 属性
    s = s.replaceAll(RegExp(r'\sonclick="[^"]*"'), '');
    // 表情图片尺寸限制
    s = s.replaceAllMapped(
      RegExp(r'<img([^>]*)class="smiley"([^>]*)>'),
      (m) => '<img${m.group(1)}style="width:24px;height:24px;vertical-align:middle"${m.group(2)}>',
    );
    return s;
  }
}
