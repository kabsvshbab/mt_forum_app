import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';

/// 帖子模型
class ThreadPost {
  final int tid;
  final String title;
  final String author;
  final String authorAvatar;
  final int replies;
  final int views;
  final String lastPostTime;
  final String? lastPostAuthor;
  final bool isSticky;
  final String? typeLabel;

  const ThreadPost({
    required this.tid,
    required this.title,
    required this.author,
    this.authorAvatar = '',
    this.replies = 0,
    this.views = 0,
    this.lastPostTime = '',
    this.lastPostAuthor,
    this.isSticky = false,
    this.typeLabel,
  });
}

/// 版块模型
class Forum {
  final int fid;
  final String name;
  final String description;
  final int todayPosts;
  final int totalThreads;
  final String? icon;

  const Forum({
    required this.fid,
    required this.name,
    this.description = '',
    this.todayPosts = 0,
    this.totalThreads = 0,
    this.icon,
  });
}

/// 楼层模型
class Post {
  final int pid;
  final int tid;
  final String author;
  final String authorAvatar;
  final String authorLevel;
  final String content;    // 已处理的 HTML 内容
  final String postTime;
  final int floorNumber;
  final String? quoteContent;

  const Post({
    required this.pid,
    required this.tid,
    required this.author,
    this.authorAvatar = '',
    this.authorLevel = '',
    required this.content,
    this.postTime = '',
    this.floorNumber = 1,
    this.quoteContent,
  });
}

/// Discuz HTML 解析器
class DiscuzParser {
  /// 解析版块列表（首页）
  static List<Forum> parseForumIndex(String html) {
    final doc = html_parser.parse(html);
    final forums = <Forum>[];
    final rows = doc.querySelectorAll('.fl_tb tr, tr.fl_row');
    for (final row in rows) {
      final link = row.querySelector('h2 a, .fl_g h2 a, td h2 a');
      if (link == null) continue;
      final href = link.attributes['href'] ?? '';
      final fidMatch = RegExp(r'fid=(\d+)').firstMatch(href);
      if (fidMatch == null) continue;
      final todayEl = row.querySelector('.fl_i_nums span, .num span');
      forums.add(Forum(
        fid: int.parse(fidMatch.group(1)!),
        name: link.text.trim(),
        description: row.querySelector('.fl_g p, .fl_inp')?.text.trim() ?? '',
        todayPosts: int.tryParse(todayEl?.text.trim() ?? '0') ?? 0,
      ));
    }
    return forums;
  }

  /// 解析版块帖子列表
  static List<ThreadPost> parseThreadList(String html) {
    final doc = html_parser.parse(html);
    final threads = <ThreadPost>[];
    final bodies = doc.querySelectorAll('#threadlisttableid tbody');
    for (final tbody in bodies) {
      final id = tbody.id; // normalthread_123 或 stickthread_123
      final tidMatch = RegExp(r'(\d+)').firstMatch(id);
      if (tidMatch == null) continue;
      final titleEl = tbody.querySelector('th a.s.xst, th a[href*="viewthread"]');
      if (titleEl == null) continue;
      final authorEl = tbody.querySelector('td.by cite a, td.by a');
      final replyEl = tbody.querySelector('td.num a, td.num em');
      final viewsEl = tbody.querySelector('td.num em');
      final lastPostEl = tbody.querySelector('td.by:last-child em a, td.by em');
      final typeEl = tbody.querySelector('th em a, th .typeid');

      final href = titleEl.attributes['href'] ?? '';
      final hrefTid = RegExp(r'tid=(\d+)').firstMatch(href);

      threads.add(ThreadPost(
        tid: int.parse(hrefTid?.group(1) ?? tidMatch.group(1)!),
        title: titleEl.text.trim(),
        author: authorEl?.text.trim() ?? '',
        replies: int.tryParse(replyEl?.text.trim() ?? '0') ?? 0,
        views: int.tryParse(viewsEl?.text.trim() ?? '0') ?? 0,
        lastPostTime: lastPostEl?.text.trim() ?? '',
        isSticky: id.startsWith('stickthread'),
        typeLabel: typeEl?.text.trim(),
      ));
    }
    return threads;
  }

  /// 解析帖子详情楼层
  static List<Post> parsePostList(String html, int tid) {
    final doc = html_parser.parse(html);
    final posts = <Post>[];
    final postDivs = doc.querySelectorAll('div[id^="post_"]');
    int floor = 1;
    for (final div in postDivs) {
      final pidMatch = RegExp(r'post_(\d+)').firstMatch(div.id);
      if (pidMatch == null) continue;
      final authorEl = div.querySelector('.authi .xw1, .authi a, .pi strong a');
      final avatarEl = div.querySelector('.avatar img, .avt img');
      final timeEl = div.querySelector('.authi em, .pi .xg1 em');
      final contentEl = div.querySelector('td.t_f, .postmessage, .t_fsz .t_f');
      final levelEl = div.querySelector('.authi .xw0, .pi em');

      String avatar = avatarEl?.attributes['src'] ?? '';
      if (avatar.startsWith('/')) avatar = 'https://bbs.binmt.cc$avatar';

      posts.add(Post(
        pid: int.parse(pidMatch.group(1)!),
        tid: tid,
        author: authorEl?.text.trim() ?? '',
        authorAvatar: avatar,
        authorLevel: levelEl?.text.trim() ?? '',
        content: contentEl?.innerHtml ?? '',
        postTime: timeEl?.text.trim() ?? '',
        floorNumber: floor++,
      ));
    }
    return posts;
  }

  /// 提取 formhash
  static String? extractFormHash(String html) {
    return RegExp(r'name="formhash" value="([a-z0-9]{8})"')
        .firstMatch(html)
        ?.group(1);
  }

  /// 提取分页总数
  static int extractMaxPage(String html) {
    final doc = html_parser.parse(html);
    final pgEls = doc.querySelectorAll('.pg a, .pg strong');
    int max = 1;
    for (final el in pgEls) {
      final v = int.tryParse(el.text.trim());
      if (v != null && v > max) max = v;
    }
    return max;
  }

  /// 提取登录错误信息
  static String? extractLoginError(String html) {
    final doc = html_parser.parse(html);
    return doc.querySelector('#messagetext p, .alert_error, #returnmessage4')
        ?.text
        .trim();
  }

  /// 检查是否登录成功
  static bool isLoginSuccess(String html, Set<String> cookieNames) {
    return cookieNames.any((n) => n.contains('_auth')) ||
        html.contains('succeedhandle') ||
        html.contains('登录成功');
  }
}