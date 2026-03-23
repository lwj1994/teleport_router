import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teleport_router/teleport_router.dart';

void main() {
  test('TeleportStatefulShellRouteInfo defaults to opaque true', () {
    final route = TeleportStatefulShellRouteInfo(
      builder: (context, shell) => shell,
      branches: const [],
    );

    expect(route.opaque, isTrue);
  });
}
