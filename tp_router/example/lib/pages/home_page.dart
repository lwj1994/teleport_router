import 'package:example/tp_router.g.dart';
import 'package:flutter/material.dart';
import 'package:tp_router/tp_router.dart';

/// Home page - the initial route.
///
/// Usage:
/// ```dart
/// context.tpRouter.goPath('/');
/// // or type-safe:
/// // HomeRoute().tp(context, clearHistory: true);
/// ```
@TpRoute(path: '/', isInitial: true)
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to TpRouter Example!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Using context.tpRouter extension
                // context.tpRouter.push('/user/123?name=John&age=25');
                UserRoute(id: 123, name: 'John', age: 25).tp(context);
              },
              child: const Text('Go to User Page'),
            ),
          ],
        ),
      ),
    );
  }
}
