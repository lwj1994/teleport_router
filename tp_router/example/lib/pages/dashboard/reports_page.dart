import 'package:flutter/material.dart';
import 'package:tp_router/tp_router.dart';

@TpRoute(path: '/dashboard/reports', parentNavigatorKey: 'dashboard')
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () => context.tpRouter.pop(),
            child: const Text('Back to Overview'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: 20,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.file_copy),
                title: Text('Report #${index + 1}'),
                subtitle: Text(
                    'Generated on ${DateTime.now().toString().split(' ')[0]}'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening Report #${index + 1}')),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
