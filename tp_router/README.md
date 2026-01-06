# TpRouter

基于 `go_router` 的简化 Flutter 路由管理库。只需一行注解即可自动集成路由！

## 特性

- 🎯 **一行注解**：只需 `@TpRoute(path: '/xxx')` 标记页面类
- 🔄 **自动类型转换**：参数自动从 String 转换为 int, double, bool 等
- 📦 **单文件输出**：所有路由统一生成到 `tp_router.g.dart`
- 🔌 **Context 扩展**：便捷导航 `context.tpPush('/path')`
- 🌐 **go_router 兼容**：完全访问底层 go_router 功能

## 项目结构

```
tp_router/
├── tp_router_annotation/  # 纯 Dart 注解（无 Flutter 依赖）
├── tp_router/             # Flutter 路由实现
└── tp_router_generator/   # Build runner 代码生成器
```

## 安装

```yaml
dependencies:
  tp_router:
    path: ../tp_router
  tp_router_annotation:
    path: ../tp_router_annotation

dev_dependencies:
  build_runner: ^2.4.0
  tp_router_generator:
    path: ../tp_router_generator
```

## 快速开始

### 1. 简单页面路由

```dart
import 'package:flutter/material.dart';
import 'package:tp_router/tp_router.dart';

@TpRoute(path: '/', isInitial: true)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () => context.tpPush('/user/123?name=John'),
        child: const Text('Go to User'),
      ),
    );
  }
}
```

### 2. 带参数的页面

```dart
import 'package:flutter/material.dart';
import 'package:tp_router/tp_router.dart';

@TpRoute(path: '/user/:id', name: 'user')
class UserPage extends StatelessWidget {
  @Path('id')        // 从路径提取: /user/:id
  final int id;

  @Query()           // 从查询参数提取: ?name=xxx
  final String name;

  @Query()           // 自动 int 转换: ?age=xx
  final int age;

  const UserPage({
    required this.id,
    required this.name,
    required this.age,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text('User $id: $name, age $age');
  }
}
```

### 3. 复杂对象参数

复杂类型自动从 `extra` 数据中提取：

```dart
@TpRoute(path: '/detail')
class DetailPage extends StatelessWidget {
  final UserModel user;  // 自动从 extra 提取

  const DetailPage({required this.user, super.key});
}

// 导航时传递 extra 数据
context.tpPush('/detail', extra: {'user': myUserModel});
```

### 4. 运行 Build Runner

```bash
dart run build_runner build
```

生成单个文件：`lib/tp_router.g.dart`

### 5. 初始化路由

```dart
import 'package:flutter/material.dart';
import 'package:tp_router/tp_router.dart';
import 'tp_router.g.dart';  // 生成的文件

void main() {
  final router = TpRouter(routes: $tpRoutes);
  runApp(MaterialApp.router(routerConfig: router.routerConfig));
}
```

## 注解

### @TpRoute

标记一个类为路由页面。

```dart
@TpRoute(
  path: '/user/:id',  // 必需：URL 路径
  name: 'user',       // 可选：路由名称
  isInitial: true,    // 可选：初始路由
)
```

### @Path

从 URL 路径提取参数。

```dart
@Path()         // 使用字段名作为参数名
@Path('userId') // 使用自定义参数名
final int id;
```

### @Query

从查询字符串提取参数。

```dart
@Query()            // ?name=xxx
@Query('page_size') // ?page_size=10
final int pageSize;
```

## 类型转换

| 类型 | 转换方式 |
|------|----------|
| `String` | 直接使用 |
| `int` | `int.tryParse()` |
| `double` | `double.tryParse()` |
| `bool` | `'true'/'1'/'yes'` → `true` |
| 复杂类型 | 从 `extra` 提取 |

## Context 扩展

```dart
// 导航
context.tpGo('/home');        // 替换当前页面
context.tpPush('/user/123');  // 压入新页面
context.tpPop();              // 弹出当前页面

// 状态
context.tpCanPop;             // 是否可以弹出
context.tpLocation;           // 当前路径

// 获取参数
context.tpParam('name');      // 获取 String 参数
context.tpParamInt('id');     // 获取 int 参数
context.tpExtra<T>('user');   // 获取 extra 数据
```

## 生成的代码

运行 `build_runner` 后，生成单个文件 `lib/tp_router.g.dart`：

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

import 'package:tp_router/tp_router.dart';
import 'package:example/pages/home_page.dart';
import 'package:example/pages/user_page.dart';

TpRouteInfo get $homePageRoute => TpRouteInfo(...);
TpRouteInfo get $userPageRoute => TpRouteInfo(...);

List<TpRouteInfo> get $tpRoutes => [
  $homePageRoute,
  $userPageRoute,
];
```

## License

MIT License
