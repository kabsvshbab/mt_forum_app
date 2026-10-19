import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../core/api/discuz_client.dart';
import '../core/api/discuz_endpoints.dart';
import '../core/parser/discuz_parser.dart';

final clientProvider = FutureProvider<DiscuzClient>((ref) => DiscuzClient.getInstance());

final forumsProvider = FutureProvider<List<Forum>>((ref) async {
  final client = await ref.watch(clientProvider.future);
  final resp = await client.dio.get(DiscuzEndpoints.forumIndex);
  return DiscuzParser.parseForumIndex(resp.data.toString());
});

final threadsProvider = FutureProvider.family<List<ThreadPost>, ({int fid, int page})>(
  (ref, params) async {
    final client = await ref.watch(clientProvider.future);
    final resp = await client.dio.get(DiscuzEndpoints.forumDisplay(params.fid, page: params.page));
    return DiscuzParser.parseThreadList(resp.data.toString());
  },
);

final postsProvider = FutureProvider.family<List<Post>, ({int tid, int page})>(
  (ref, params) async {
    final client = await ref.watch(clientProvider.future);
    final resp = await client.dio.get(DiscuzEndpoints.viewThread(params.tid, page: params.page));
    return DiscuzParser.parsePostList(resp.data.toString(), params.tid);
  },
);

class AuthState {
  final bool isLoggedIn;
  final String? username;
  final String? error;
  final bool loading;
  const AuthState({this.isLoggedIn = false, this.username, this.error, this.loading = false});
  AuthState copyWith({bool? isLoggedIn, String? username, String? error, bool? loading}) =>
    AuthState(isLoggedIn: isLoggedIn ?? this.isLoggedIn, username: username ?? this.username, error: error, loading: loading ?? this.loading);
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> init() async {
    final client = await DiscuzClient.getInstance();
    final loggedIn = await client.isLoggedIn();
    state = state.copyWith(isLoggedIn: loggedIn);
  }

  Future<bool> login(String username, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final client = await DiscuzClient.getInstance();
      final formhash = await client.fetchFormHash();
      final resp = await client.dio.post(
        DiscuzEndpoints.loginSubmit,
        data: {
          'formhash': formhash,
          'referer': 'https://bbs.binmt.cc/forum.php',
          'loginfield': 'username',
          'username': username,
          'password': password,
          'questionid': '0',
          'answer': '',
          'cookietime': '2592000',
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      final html = resp.data.toString();
      final cookies = await client.cookieJar.loadForRequest(Uri.parse(DiscuzEndpoints.base));
      final cookieNames = cookies.map((c) => c.name).toSet();
      final success = DiscuzParser.isLoginSuccess(html, cookieNames);
      if (success) {
        state = state.copyWith(isLoggedIn: true, username: username, loading: false);
        return true;
      } else {
        final err = DiscuzParser.extractLoginError(html) ?? '登录失败';
        state = state.copyWith(loading: false, error: err);
        return false;
      }
    } catch (e) {
      state = state.copyWith(loading: false, error: '网络错误：$e');
      return false;
    }
  }

  Future<void> logout() async {
    final client = await DiscuzClient.getInstance();
    await client.logout();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

final replyProvider = FutureProvider.family<bool, ({int fid, int tid, String message})>(
  (ref, params) async {
    final client = await ref.watch(clientProvider.future);
    final formhash = await client.fetchFormHash();
    final resp = await client.dio.post(
      DiscuzEndpoints.replySubmit(params.fid, params.tid),
      data: {
        'formhash': formhash,
        'message': params.message,
        'subject': '',
        'usesig': '1',
        'replysubmit': 'yes',
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final html = resp.data.toString();
    return html.contains('回复发布成功') || html.contains('succeedhandle') || !html.contains('errorhandle');
  },
);
