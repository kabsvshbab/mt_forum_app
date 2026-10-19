import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'ui/theme/liquid_theme.dart';
import 'ui/pages/splash/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('drafts');
  await Hive.openBox('settings');
  runApp(const ProviderScope(child: MTForumApp()));
}

class MTForumApp extends ConsumerWidget {
  const MTForumApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'MT论坛',
      debugShowCheckedModeBanner: false,
      theme: LiquidTheme.light(),
      darkTheme: LiquidTheme.dark(),
      themeMode: ThemeMode.dark,
      home: const SplashPage(),
    );
  }
}
