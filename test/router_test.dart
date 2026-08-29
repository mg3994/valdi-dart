import 'package:test/test.dart';
import 'package:valdi_dart/valdi_dart.dart';
import 'package:kaisel_core/kaisel_core.dart';

sealed class TestRoute extends KaiselRoute {
  const TestRoute();
}

final class HomeRoute extends TestRoute {
  const HomeRoute();
}

final class DetailRoute extends TestRoute {
  final String id;
  const DetailRoute(this.id);

  @override
  List<Object?> get props => [id];
}

final class ModalTestRoute extends TestRoute implements KaiselModalRoute<String> {
  const ModalTestRoute();
}

void main() {
  group('AppRouter (kaisel_core) Navigation Tests', () {
    late AppRouter<TestRoute> router;

    setUp(() {
      router = AppRouter<TestRoute>(initialRoute: const HomeRoute());
      router.registerRoute<HomeRoute>((route) => const Component.text('Home Screen'));
      router.registerRoute<DetailRoute>((route) => Component.text('Detail Screen: ${route.id}'));
    });

    test('Initial route builds correctly', () {
      final tree = router.buildCurrentTree();
      expect(tree, equals(const Component.text('Home Screen')));
    });

    test('push and pop update active route and component tree', () async {
      await router.push(const DetailRoute('42'));
      expect(router.buildCurrentTree(), equals(const Component.text('Detail Screen: 42')));

      final popped = await router.pop();
      expect(popped, isTrue);
      expect(router.buildCurrentTree(), equals(const Component.text('Home Screen')));
    });

    test('replaceTop changes current route', () async {
      await router.replaceTop(const DetailRoute('99'));
      expect(router.buildCurrentTree(), equals(const Component.text('Detail Screen: 99')));
    });

    test('presentModal and dismissModal work as expected', () async {
      final modalFuture = router.presentModal<String>(const ModalTestRoute());
      router.dismissModal<String>('Modal Success Result');
      final result = await modalFuture;
      expect(result, equals('Modal Success Result'));
    });
  });
}
