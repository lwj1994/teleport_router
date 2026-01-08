import 'package:example/routes/route.gr.dart';
import 'package:example/routes/nav_keys.dart';
import 'package:flutter/material.dart';
import 'package:tp_router/tp_router.dart';

/// Home page - the initial route.
///
/// Usage:
/// ```dart
/// context.tpRouter.tp(HomeRoute());
/// ```
@TpRoute(
    path: '/', isInitial: true, parentNavigatorKey: MainNavKey, branchIndex: 0)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _result;

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
            if (_result != null)
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.amber.withOpacity(0.2),
                child: Text('Result from Details: $_result'),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                const ProtectedRoute().tp(context);
              },
              child: const Text('Go to Protected Page'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                const DetailsRoute(title: 'From Home').tp(context);
              },
              child: const Text('Go to Details'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Type-safe navigation with unified tp() method
                UserRoute(id: 123, name: 'John', age: 25).tp(context);
              },
              child: const Text('Go to User Page'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // DetailsPage has custom slide transition (500ms enter, 300ms exit)
                DetailsRoute(title: 'Custom Transition Demo').tp(context);
              },
              child: const Text('Go to Details (Custom Transition)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final result = await DetailsRoute(
                  title: 'Waiting for result...',
                ).tp<String>(context);

                if (mounted) {
                  setState(() {
                    _result = result;
                  });
                }
              },
              child: const Text('Push Details (Wait Result)'),
            ),
            const Divider(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                // Navigate to route removal demo
                const RouteRemovalDemoRoute().tp(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              label: const Text('Route Removal Demo'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.cast_connected),
              onPressed: () {
                // Remote push to Dashboard's navigator
                // This demonstrates controlling a different navigator stack using its NavKey!
                // Note: We MUST pass null for context when using navigatorKey, as they are mutually exclusive.
                
                const AnalyticsRoute(title: 'Pushed Remotely from Home')
                    .tp(null, navigatorKey: const DashboardNavKey());

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Pushed to Dashboard! Go to Dashboard tab to see it.'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              label: const Text('Remote Push to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}
