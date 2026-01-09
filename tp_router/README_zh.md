# TpRouter 🚀

> 告别路由表地狱！用注解优雅地管理 Flutter 路由 ✨

| Package | Version |
|---------|---------|
| [tp_router](https://pub.dev/packages/tp_router) | [![pub package](https://img.shields.io/pub/v/tp_router.svg)](https://pub.dev/packages/tp_router) |
| [tp_router_annotation](https://pub.dev/packages/tp_router_annotation) | [![pub package](https://img.shields.io/pub/v/tp_router_annotation.svg)](https://pub.dev/packages/tp_router_annotation) |
| [tp_router_generator](https://pub.dev/packages/tp_router_generator) | [![pub package](https://img.shields.io/pub/v/tp_router_generator.svg)](https://pub.dev/packages/tp_router_generator) |

**底层基于 [go_router](https://pub.dev/packages/go_router)**（Flutter 官方路由包），核心功能稳如老狗 🐕 深度链接、Web 支持、嵌套导航全都有！TpRouter 只是在上面加了一层更人性化的注解 API，让你写起来更爽～

---

## 📑 目录

- [为什么选择 TpRouter](#-为什么选择-tprouter)
- [安装](#-安装)
- [快速上手](#-快速上手)
- [参数传递](#-参数传递)
- [Shell 嵌套路由](#-shell-嵌套路由)
- [路由守卫](#-路由守卫)
- [响应式路由](#-响应式路由)
- [页面配置](#-页面配置)
- [转场动画](#-转场动画)
- [TpRouter 配置项](#-tprouter-配置项)

---

## ✨ 为什么选择 TpRouter

| 痛点 | go_router 原生 | TpRouter 解决方案 |
|------|---------------|------------------|
| 路由表维护 | 手动维护嵌套结构 😵 | 注解自动生成，0 配置 |
| 类型安全 | 手拼 URL 字符串 | `UserRoute(id: 1).tp()` |
| 参数传递 | 手动解析 `state.params` | `@Path` `@Query` 自动注入 |
| Shell 嵌套 | 复杂的手动配置 | 只需声明 `parentNavigatorKey` |
| 守卫逻辑 | 全局 redirect 函数 | 类型安全的 `TpRedirect<T>` |

**一句话总结**：用 go_router 的稳定内核 + 更优雅的开发体验 💪

---

## 📦 安装

```yaml
dependencies:
  tp_router: ^0.5.1
  tp_router_annotation: ^0.5.0

dev_dependencies:
  build_runner: ^2.4.0
  tp_router_generator: ^0.5.0
```

生成路由代码：
```bash
dart run build_runner build
```

---

## 🚀 快速上手

### 3 步搞定基础路由！

**Step 1️⃣ 给页面加注解**
```dart
@TpRoute(path: '/login')
class LoginPage extends StatelessWidget { ... }

@TpRoute(path: '/home', isInitial: true) // 首页加 isInitial
class HomePage extends StatelessWidget { ... }
```

**Step 2️⃣ 初始化 Router**
```dart
import 'routes/route.gr.dart'; // 生成的文件

void main() {
  final router = TpRouter(routes: tpRoutes);
  
  runApp(MaterialApp.router(
    routerConfig: router.routerConfig,
  ));
}
```

**Step 3️⃣ 开始导航！**
```dart
// 跳转
HomeRoute().tp();

// 带返回值
final result = await SelectRoute().tp<String>();

// 替换当前页
LoginRoute().tp(replacement: true);

// 清空历史栈（类似 go）
HomeRoute().tp(clearHistory: true);
```

就这么简单！不用维护路由表，不用手拼 URL 🎉

---

## 📦 参数传递

TpRouter 支持三种参数类型，全部自动解析！

### 路径参数 `@Path`

```dart
@TpRoute(path: '/user/:id')
class UserPage extends StatelessWidget {
  const UserPage({required this.userId});
  
  @Path('id')
  final String userId;
}

// 导航
UserRoute(userId: '123').tp(); // -> /user/123
```

### 查询参数 `@Query`

```dart
@TpRoute(path: '/search')
class SearchPage extends StatelessWidget {
  const SearchPage({this.keyword, this.page});
  
  @Query('q')
  final String? keyword;
  
  @Query('page')
  final int? page; // 自动转 int！
}

// 导航
SearchRoute(keyword: 'flutter', page: 2).tp(); // -> /search?q=flutter&page=2
```

### Extra 复杂对象

不想序列化？直接传对象！

```dart
@TpRoute(path: '/detail')
class DetailPage extends StatelessWidget {
  const DetailPage({required this.item});
  
  final Product item; // 复杂对象，内存传递
}

// 导航
DetailRoute(item: myProduct).tp();
```

> ⚠️ Extra 对象在浏览器刷新后会丢失，需要持久化的数据请用 Path/Query

### 组合使用

```dart
@TpRoute(path: '/order/:orderId')
class OrderPage extends StatelessWidget {
  const OrderPage({
    required this.orderId,
    this.from,
    required this.orderData,
  });
  
  @Path('orderId')
  final String orderId;
  
  @Query('from')
  final String? from;
  
  final Order orderData; // Extra
}
```

---

## 🐚 Shell 嵌套路由

底部导航栏？抽屉菜单？TpRouter 让嵌套路由变得超简单！

### Step 1️⃣ 定义 NavKey

```dart
// Shell 的 Key
class MainShellKey extends TpNavKey {
  const MainShellKey() : super('main');
}

// 各个 Tab 的 Key
class HomeTabKey extends TpNavKey {
  const HomeTabKey() : super('main', branch: 0);
}

class ProfileTabKey extends TpNavKey {
  const ProfileTabKey() : super('main', branch: 1);
}
```

### Step 2️⃣ 定义 Shell

```dart
@TpShellRoute(
  navigatorKey: MainShellKey,
  branchKeys: [HomeTabKey, ProfileTabKey],
  isIndexedStack: true, // 保持各 tab 状态
)
class MainShell extends StatelessWidget {
  final TpStatefulNavigationShell navigationShell;
  const MainShell({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.tp(i), // 切换 tab
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '首页'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }
}
```

### Step 3️⃣ 关联子路由

只需要声明 `parentNavigatorKey`，生成器自动搞定嵌套关系！

```dart
@TpRoute(path: '/home', parentNavigatorKey: HomeTabKey)
class HomePage extends StatelessWidget { ... }

@TpRoute(path: '/profile', parentNavigatorKey: ProfileTabKey)
class ProfilePage extends StatelessWidget { ... }
```

**就这样！不用手动维护路由树结构** 🎯

---

## 🛡️ 路由守卫

### 页面级重定向

```dart
class AuthGuard extends TpRedirect<ProtectedRoute> {
  @override
  FutureOr<TpRouteData?> handle(BuildContext context, ProtectedRoute route) {
    if (!AuthService.isLoggedIn) {
      return LoginRoute(); // 没登录？踢走！
    }
    return null; // 返回 null = 放行
  }
}

@TpRoute(path: '/vip', redirect: AuthGuard)
class VipPage extends StatelessWidget { ... }
```

### 全局重定向

```dart
final router = TpRouter(
  routes: tpRoutes,
  redirect: (context, state) {
    if (needOnboarding && state.fullPath != '/onboarding') {
      return OnboardingRoute();
    }
    return null;
  },
);
```

### 返回拦截 OnExit

表单没保存就想跑？拦住！

```dart
class SaveGuard extends TpOnExit<EditRoute> {
  @override
  FutureOr<bool> onExit(BuildContext context, EditRoute route) async {
    if (hasUnsavedChanges) {
      return await showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: Text('有未保存的更改'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: Text('取消')),
            TextButton(onPressed: () => Navigator.pop(c, true), child: Text('放弃')),
          ],
        ),
      ) ?? false;
    }
    return true;
  }
}

@TpRoute(path: '/edit', onExit: SaveGuard)
class EditPage extends StatelessWidget { ... }
```

---

## 🔄 响应式路由

### 核心问题：登录后卡在登录页？

这是 go_router 新手最常遇到的坑！原因是 **Router 不知道登录状态变了**。

### 解决方案：refreshListenable

```dart
// 1. 创建可监听的 Auth 服务
class AuthService extends ChangeNotifier {
  static final instance = AuthService();
  
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    notifyListeners(); // 🔔 通知 Router！
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}

// 2. 传给 TpRouter
final router = TpRouter(
  routes: tpRoutes,
  refreshListenable: AuthService.instance, // 👈 关键！
  redirect: (context, state) {
    final loggedIn = AuthService.instance.isLoggedIn;
    final onLoginPage = state.fullPath == '/login';
    
    if (!loggedIn && !onLoginPage) return LoginRoute();
    if (loggedIn && onLoginPage) return HomeRoute();
    return null;
  },
);
```

**现在当你调用 `AuthService.instance.login()` 时，Router 会自动重新评估并跳转！** 🪄

---

## 📄 页面配置

注解里可以配置超多东西！

### 页面类型 TpPageType

```dart
@TpRoute(
  path: '/settings',
  type: TpPageType.cupertino, // 强制 iOS 风格
)
class SettingsPage extends StatelessWidget { ... }
```

| 类型 | 说明 |
|------|------|
| `auto` | 自动适配平台（默认） |
| `material` | Android 风格 |
| `cupertino` | iOS 风格 |
| `swipeBack` | 全屏滑动返回 |
| `custom` | 自定义 Page |

### 模态弹窗

```dart
@TpRoute(
  path: '/create',
  fullscreenDialog: true, // iOS 风格模态，显示 X 关闭按钮
)
class CreatePage extends StatelessWidget { ... }
```

### 透明页面

做底部弹出框、蒙层？用这个！

```dart
@TpRoute(
  path: '/overlay',
  opaque: false,                    // 透明背景
  barrierColor: Color(0x80000000),  // 半透明黑色蒙层
  barrierDismissible: true,         // 点击蒙层关闭
)
class OverlayPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Text('我是底部弹窗'),
      ),
    );
  }
}
```

### @TpRoute 完整参数

```dart
@TpRoute(
  // 核心
  path: '/user/:id',              // 路径
  isInitial: false,               // 是否初始路由
  parentNavigatorKey: SomeNavKey, // 父级 Shell
  
  // 守卫
  redirect: AuthGuard,            // 重定向
  onExit: SaveGuard,              // 返回拦截
  
  // 页面类型
  type: TpPageType.auto,
  pageBuilder: MyCustomPage,      // 自定义 Page
  
  // 转场
  transition: TpSlideTransition(),
  transitionDuration: Duration(milliseconds: 300),
  reverseTransitionDuration: Duration(milliseconds: 300),
  
  // 弹窗/模态
  fullscreenDialog: false,
  opaque: true,
  barrierDismissible: false,
  barrierColor: null,
  barrierLabel: null,
  
  // 状态
  maintainState: true,
)
```

### @TpShellRoute 完整参数

```dart
@TpShellRoute(
  // 核心
  navigatorKey: MainNavKey,           // 必填
  parentNavigatorKey: RootNavKey,     // 嵌套 Shell
  isIndexedStack: true,               // 保持分支状态
  branchKeys: [HomeKey, ProfileKey],  // 分支 Key 列表
  
  // 观察者
  observers: [AnalyticsObserver],     // NavigatorObserver 列表
  
  // 页面配置（同 TpRoute）
  type: TpPageType.material,
  fullscreenDialog: false,
  opaque: true,
  // ...
)
```

---

## 🎨 转场动画

### 内置动画

```dart
@TpRoute(
  path: '/detail',
  transition: TpSlideTransition(),    // 滑动
  // TpFadeTransition()               // 淡入淡出
  // TpScaleTransition()              // 缩放
  // TpNoTransition()                 // 无动画
  // TpCupertinoPageTransition()      // iOS 风格
  transitionDuration: Duration(milliseconds: 300),
)
```

### 全局默认动画

```dart
final router = TpRouter(
  routes: tpRoutes,
  defaultTransition: TpSlideTransition(),
  defaultTransitionDuration: Duration(milliseconds: 250),
);
```

### 滑动返回

```dart
final router = TpRouter(
  routes: tpRoutes,
  defaultPageType: TpPageType.swipeBack, // 全局开启
);
```

---

## ⚙️ TpRouter 配置项

```dart
TpRouter(
  routes: tpRoutes,
  
  // 初始位置
  initialLocation: '/home',
  
  // 全局重定向
  redirect: (context, state) => null,
  
  // 响应式触发器
  refreshListenable: authNotifier,
  
  // 错误页
  errorBuilder: (context, state) => ErrorPage(error: state.error),
  
  // 调试日志
  debugLogDiagnostics: true,
  
  // 转场默认值
  defaultTransition: TpSlideTransition(),
  defaultTransitionDuration: Duration(milliseconds: 300),
  
  // 页面类型
  defaultPageType: TpPageType.auto,
  
  // 重定向次数限制
  redirectLimit: 5,
  
  // 状态恢复
  restorationScopeId: 'app_router',
);
```

### build.yaml 配置

```yaml
targets:
  $default:
    builders:
      tp_router_generator:
        options:
          output: lib/routes/app_routes.dart # 自定义输出路径
```

---

## 💬 最后

有问题欢迎提 Issue！觉得好用的话给个 ⭐️ 吧～

**Happy Routing!** 🎉
