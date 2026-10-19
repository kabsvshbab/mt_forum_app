import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'discuz_endpoints.dart';

/// Discuz HTTP 客户端（含 Cookie 持久化）
class DiscuzClient {
  static DiscuzClient? _instance;
  late final Dio dio;
  late final PersistCookieJar cookieJar;

  DiscuzClient._();

  static Future<DiscuzClient> getInstance() async {
    if (_instance != null) return _instance!;
    final c = DiscuzClient._();
    await c._init();
    _instance = c;
    return c;
  }

  Future<void> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    cookieJar = PersistCookieJar(storage: FileStorage('${dir.path}/.cookies/'));
    dio = Dio(BaseOptions(
      baseUrl: DiscuzEndpoints.base,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      followRedirects: true,
      maxRedirects: 5,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Mobile Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'zh-CN,zh;q=0.9',
      },
    ));
    dio.interceptors.add(CookieManager(cookieJar));
    dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: false));
  }

  /// 获取 formhash（Discuz 全局提交令牌）
  Future<String> fetchFormHash() async {
    final resp = await dio.get('/forum.php');
    final match = RegExp(r'name="formhash" value="([a-z0-9]{8})"').firstMatch(resp.data.toString());
    return match?.group(1) ?? '';
  }

  /// 检查登录状态
  Future<bool> isLoggedIn() async {
    final cookies = await cookieJar.loadForRequest(Uri.parse(DiscuzEndpoints.base));
    return cookies.any((c) => c.name.endsWith('_auth') && c.value.isNotEmpty);
  }

  /// 清除登录态
  Future<void> logout() async {
    await cookieJar.deleteAll();
  }
}