# MT论坛 - iOS 26 液态玻璃客户端

基于 Flutter 开发的 MT论坛 (bbs.binmt.cc) Android 客户端，采用 iOS 26 液态玻璃风格 UI。

## 特性

- **液态玻璃 UI**：参考 [bytemanxie/liquid-glass](https://github.com/bytemanxie/liquid-glass)，在 Flutter 中复刻 iOS 26 液态玻璃效果
- **完整论坛功能**：版块浏览、帖子列表、帖子详情、回复、发帖、登录
- **深色主题**：全局液态玻璃深色主题，浮动光斑背景
- **流畅动画**：弹簧物理延迟跟随、60fps 滚动
- **数据持久化**：Cookie 持久化登录、草稿箱本地缓存

## 技术栈

| 层 | 技术 |
|---|---|
| UI 框架 | Flutter 3.22 + Material 3 |
| 状态管理 | Riverpod |
| 网络 | Dio + CookieJar |
| HTML 解析 | html (Dart) |
| 内容渲染 | flutter_html (BBCode) |
| 本地存储 | Hive + SharedPreferences |

## 界面预览

- 液态玻璃卡片：28px 连续圆角、24σ 高斯模糊、双层柔光阴影
- 延迟跟随物理：拖拽卡片时弹簧回弹动画
- 浮动光斑背景：多层渐变光斑缓慢移动
- 玻璃底部导航：悬浮毛玻璃 Tab 栏

## 构建

```bash
flutter pub get
flutter build apk --release --split-per-abi
```

## GitHub Actions

推送到 main 分支后自动构建 APK，在 Actions 页面下载。
