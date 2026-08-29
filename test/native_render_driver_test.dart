import 'package:test/test.dart';
import 'package:valdi_dart/valdi_dart.dart';

void main() {
  group('NativeRenderDriver Platform Bridge Tests', () {
    late DefaultNativeRenderDriver driver;
    late Reconciler reconciler;

    setUp(() {
      driver = DefaultNativeRenderDriver();
      reconciler = const Reconciler();
    });

    test('mount translates component tree into native view nodes', () {
      final tree = VStack(
        children: [
          const Component.text('Native Title'),
          Button(child: const Component.text('Click'), onClickEventId: 'btn_1'),
        ],
      );

      final nativeRoot = driver.mount(tree);

      expect(nativeRoot.type, contains('AndroidLinearLayoutVertical'));
      expect(nativeRoot.children.length, equals(2));
      expect(nativeRoot.children[0].type, equals('NativeTextView'));
      expect(nativeRoot.children[0].attributes['text'], equals('Native Title'));
      expect(nativeRoot.children[1].type, contains('AndroidButton'));
    });

    test('applyMutations updates native view nodes', () {
      final oldTree = VStack(
        children: [
          const Component.text('Original'),
        ],
      );

      final newTree = VStack(
        children: [
          const Component.text('Updated Text'),
          const Component.text('Second Item'),
        ],
      );

      final nativeRoot = driver.mount(oldTree);
      final mutations = reconciler.diff(oldTree, newTree);

      driver.applyMutations(nativeRoot, mutations);

      expect(nativeRoot.children[0].attributes['text'], equals('Updated Text'));
      expect(nativeRoot.children.length, equals(2));
      expect(nativeRoot.children[1].attributes['text'], equals('Second Item'));
    });
  });
}
