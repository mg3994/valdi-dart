import 'package:test/test.dart';
import 'package:valdi_dart/framework/framework.dart';
import 'package:valdi_dart/routing/app_router.dart';

void main() {
  group('Routing Architecture (kaisel_core) Tests', () {
    late AppRoute homeRoute;
    late AppRoute detailsRoute;
    late AppRouter router;

    setUp(() {
      homeRoute = AppRoute('/home', () => Component.text('Home Screen'));
      detailsRoute = AppRoute('/details', () => Component.text('Details Screen'));
      router = AppRouter(initialRoute: homeRoute);
    });

    tearDown(() {
      router.dispose();
    });

    test('Initial route builds correct component', () {
      expect(router.currentRoute, equals(homeRoute));
      final comp = router.buildCurrentComponent();
      expect(comp, equals(Component.text('Home Screen')));
    });

    test('Pushing route updates stack and active component', () async {
      await router.push(detailsRoute);

      expect(router.stack.length, equals(2));
      expect(router.currentRoute, equals(detailsRoute));
      expect(router.buildCurrentComponent(), equals(Component.text('Details Screen')));
    });

    test('Popping route navigates back to previous route', () async {
      await router.push(detailsRoute);
      final popped = await router.pop();

      expect(popped, isTrue);
      expect(router.stack.length, equals(1));
      expect(router.currentRoute, equals(homeRoute));
    });

    test('Replacing top route replaces current route on stack', () async {
      await router.replace(detailsRoute);

      expect(router.stack.length, equals(1));
      expect(router.currentRoute, equals(detailsRoute));
    });
  });
}
