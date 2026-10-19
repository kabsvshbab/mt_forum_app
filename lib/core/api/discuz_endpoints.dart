/// Discuz 标准端点定义
class DiscuzEndpoints {
  static const String base = 'https://bbs.binmt.cc';

  // 首页 / 版块
  static const String forumIndex = '/forum.php';
  static String forumDisplay(int fid, {int page = 1}) =>
      '/forum.php?mod=forumdisplay&fid=$fid&page=$page';

  // 帖子
  static String viewThread(int tid, {int page = 1}) =>
      '/forum.php?mod=viewthread&tid=$tid&page=$page';

  // 登录
  static const String loginPage = '/member.php?mod=logging&action=login';
  static const String loginSubmit =
      '/member.php?mod=logging&action=login&loginsubmit=yes&loginhash=&inajax=1';

  // 回复
  static String replySubmit(int fid, int tid) =>
      '/forum.php?mod=post&action=reply&fid=$fid&tid=$tid&extra=&replysubmit=yes&infloat=yes&handlekey=fastpost';

  // 发新帖
  static String newThreadSubmit(int fid) =>
      '/forum.php?mod=post&action=newthread&fid=$fid&topicsubmit=yes';

  // 验证码
  static String seccode(String idhash) =>
      '/misc.php?mod=seccode&action=update&idhash=$idhash&modid=member::logging';

  // 用户中心
  static String profile(int uid) => '/home.php?mod=space&uid=$uid';
  static const String myThreads = '/forum.php?mod=guide&view=my';
  static const String notifications = '/home.php?mod=space&do=notice';
}