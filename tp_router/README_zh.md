# TpRouter

极简、类型安全、注解驱动的 Flutter 路由库，彻底告别路由表维护的烦恼。

| Package | Version |
|---------|---------|
| [tp_router](https://pub.dev/packages/tp_router) | [![pub package](https://img.shields.io/pub/v/tp_router.svg)](https://pub.dev/packages/tp_router) |
| [tp_router_annotation](https://pub.dev/packages/tp_router_annotation) | [![pub package](https://img.shields.io/pub/v/tp_router_annotation.svg)](https://pub.dev/packages/tp_router_annotation) |
| [tp_router_generator](https://pub.dev/packages/tp_router_generator) | [![pub package](https://img.shields.io/pub/v/tp_router_generator.svg)](https://pub.dev/packages/tp_router_generator) |

---

## 🌟 核心理念

1.  **NavKey 驱动架构**: 颠覆传统 RouteTable 维护方式，通过 Key 自动建立父子和分支关系，无需手动搭建路由树。
2.  **类型安全导航**: 自动生成路由类。使用 `UserRoute(id: 1).tp()` 代替容易拼写错误的 URL 字符串。
3.  **声明式 Shell**: 纯注解定义复杂的嵌套 UI（如底部导航栏、侧滑抽屉），支持状态保持 (`IndexedStack`)。

---

## 📦 安装

在 `pubspec.yaml` 中添加：

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

## 🚀 模块化功能指南

### 1. 路由定义 (Define Routes)

最基础的功能。只需将 `@TpRoute` 放在你的 Widget 上。

#### 基础路由
```dart
@TpRoute(path: '/login')
class LoginPage extends StatelessWidget { ... }
```

#### 参数传递
TpRouter 提供了强大的参数解析能力，支持路径参数、查询参数和复杂对象参数 (Extra)。

*   **路径参数 (`@Path`)**: URL 路径的一部分，例如 `/user/:id`。
*   **查询参数 (`@Query`)**: URL 末尾的 `?id=1`。
*   **Extra 对象**: 内存中传递的复杂对象（非序列化）。

```dart
@TpRoute(path: '/user/:id')
class UserPage extends StatelessWidget {
  const UserPage({
    @Path('id') required this.userId, // 自动从 URL 解析 :id
    @Query('from') this.fromWhere,     // 解析 ?from=...
    required this.userObj,            // 自动解析通过 extra 传递的复杂对象
  });

  final String userId;
  final String? fromWhere;
  final User userObj;
}
```

**有了 TpRouter，你可以这样优雅地跳转：**
```dart
// 无需手动拼接 URL，类型安全且直观
UserRoute(
  userId: '123',
  userObj: user, 
  fromWhere: 'home'
).tp();
```

---

### 2. Shell 与 嵌套路由 (Nested Navigation)

实现底部导航栏 (`BottomNavigationBar`)、侧边栏等持久化 UI 结构。

#### 第一步：定义 Key
定义 `TpNavKey`，它们是关联父子路由的纽带。

```dart
// 主 Shell 的标识 Key
class MainShellKey extends TpNavKey {
  const MainShellKey() : super('main_shell');
}

// 分支 Key (例如首页 Tab)
class HomeTabKey extends TpNavKey {
  const HomeTabKey() : super('main_shell_home_tab'); 
}

// 分支 Key (例如设置页 Tab)
class SettingsTabKey extends TpNavKey {
  const SettingsTabKey() : super('main_shell_settings_tab'); 
}
```

#### 第二步：定义 Shell UI
使用 `@TpShellRoute` 标注。

```dart
@TpShellRoute(
  navigatorKey: MainShellKey,          // 必填：Shell 的唯一标识
  branchKeys: [HomeTabKey, SettingsTabKey], // 定义所有分支 Key
  isIndexedStack: true,                // 推荐：启用状态保持 (IndexedStack)
)
class MainShellPage extends StatelessWidget {
  final TpStatefulNavigationShell navigationShell; // 获取 Shell 控制器
  
  const MainShellPage({required this.navigationShell, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell, // 显示当前分支的页面
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        // 使用 .tp(index) 切换分支
        onTap: (index) => navigationShell.tp(index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
```

#### 第三步：关联子路由 (Linking)
无需在 Shell 中手动引入子页面，只需在子页面声明 "谁是父亲" (`parentNavigatorKey`)。

```dart
// 属于 Home 分支的页面
@TpRoute(
  path: '/home',
  parentNavigatorKey: HomeTabKey, // <--- 关键！自动关联到 Home 分支
)
class HomePage extends StatelessWidget { ... }

// 属于 Settings 分支的页面
@TpRoute(
  path: '/settings',
  parentNavigatorKey: SettingsTabKey, // <--- 关联到 Settings 分支
)
class SettingsPage extends StatelessWidget { ... }
```
**生成器会自动识别 Key 的匹配关系，构建出完整的路由树。**

---

### 3. Key 系统详解 (NavKey System)

`TpNavKey` 不仅仅是一个 ID，它提供了上下文无关的控制能力。

#### 关联 (Linking)
如上所示，`parentNavigatorKey` 仅仅是告诉生成器这个路由“属于”哪里。这是最主要的作用。

#### 控制 (Pop)
因为 `NavKey` 绑定了特定的 `Navigator`，你可以在任何地方（甚至没有 Context 的地方，如果你通过依赖注入获取 Key 实例）控制特定导航栈的返回。

```dart
// 关闭当前的顶层页面 (无论在哪)
context.pop(); 

// 强制关闭属于 MainShellKey 关联的导航器栈顶页面
// 适用于：在深层嵌套中想专门关闭某个父级 Shell 管理的弹窗或页面
MainShellKey().pop(); 
```

---

### 4. 路由守卫与拦截 (Guards & Lifecycle)

#### 重定向 (Redirect)
用于权限控制。例如：有些页面必须登录才能看。

```dart
class AuthGuard extends TpRedirect<AdminRoute> {
  @override
  FutureOr<TpRouteData?> handle(BuildContext context, AdminRoute route) {
    if (!AuthService.isLoggedIn) {
      // 拦截当前路由，并重定向去登录页
      return LoginRoute(); 
    }
    return null; // 返回 null 表示放行
  }
}

// 在路由上通过 redirect 参数挂载
@TpRoute(path: '/admin', redirect: AuthGuard)
class AdminPage extends StatelessWidget { ... }
```

#### 页面退出拦截 (OnExit)
用于防止用户误触返回键（例如：表单编辑中未保存）。

```dart
class SaveCheckWrapper extends TpOnExit<EditorRoute> {
  @override
  FutureOr<bool> onExit(BuildContext context, EditorRoute route) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('未保存'),
        content: Text('确定要放弃修改并发起吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text('取消')),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text('退出')),
        ],
      ),
    );
    return shouldExit ?? false; // 返回 true 允许退出，false 拦截
  }
}

@TpRoute(path: '/edit', onExit: SaveCheckWrapper)
class EditorPage extends StatelessWidget { ... }
```

---

### 5. 高级配置

#### 自定义转场动画 (Transitions)
TpRouter 内置了常用的动画效果，也可自定义。

```dart
@TpRoute(
  path: '/details',
  transition: TpTransition.slide, // 内置: slide, fade, scale, none, cupertino
  transitionDuration: 300,        // 动画时长 (毫秒)
)
class DetailsPage extends StatelessWidget { ... }
```

#### 滑动返回 (Swipe Back)
TpRouter 集成了高性能的滑动返回功能。

```dart
@TpRoute(
  path: '/story',
  enableSwipeBack: true, // 开启全屏滑动返回
)
class StoryPage extends StatelessWidget { ... }
```

#### 自定义输出路径
不想让生成的路由文件和源代码混在一起？在 `build.yaml` 中配置：

```yaml
targets:
  $default:
    builders:
      tp_router_generator:
        options:
          output: lib/core/router/app_routes.dart # 指定输出文件
```

---

## 💡 初始化

最后，在你的 `main.dart` 中初始化。

```dart
import 'package:tp_router/tp_router.dart';
import 'routes/route.gr.dart'; // 引入生成的文件

void main() {
  // 1. 创建 Router 实例
  final router = TpRouter(
    routes: tpRoutes, // 生成的路由列表
  );

  runApp(MaterialApp.router(
    routerConfig: router.routerConfig, // 2. 挂载到 MaterialApp
    title: 'My App',
  ));
}
```
