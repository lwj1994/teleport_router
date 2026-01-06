写个 flutter router 路由管理，基于 go_router: ^17.0.1。 实现  

目的：
最大化简化路由的生成。实现只需1 行 注解简单配置 page 下就能自动集成。

其他高级功能可选，基于 go-router 封装。高级的功能先不做

```dart

@TpRoute(path: "/a")
class APage{
    @RouteParam(name:"name")
    final String name;
    final int age;

    APage({required this.name, required this.age});

}
```


build runner 自动收集和生成路由表信息。初始化时，自动把这个路由 桥接转成 go-router 能识别的。
```dart
class TpRouteTable{
    final List<TpRoute> routes;

}
```