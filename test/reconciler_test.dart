import 'package:test/test.dart';
import 'package:valdi_dart/valdi_dart.dart';

void main() {
  group('Reconciler Engine Tests', () {
    const reconciler = Reconciler();

    test('identical components yield no mutations', () {
      const tree1 = Component.text('Hello');
      const tree2 = Component.text('Hello');
      final mutations = reconciler.diff(tree1, tree2);
      expect(mutations, isEmpty);
    });

    test('text change produces UpdateMutation', () {
      const oldTree = Component.text('Hello');
      const newTree = Component.text('World');
      final mutations = reconciler.diff(oldTree, newTree);
      expect(mutations.length, 1);
      expect(
        mutations.first,
        equals(const UpdateMutation(
          path: [],
          oldComponent: oldTree,
          newComponent: newTree,
        )),
      );
    });

    test('attribute change produces UpdateMutation with attribute diff', () {
      const oldTree = Component.element('div', [], {'class': 'container', 'id': 'main'});
      const newTree = Component.element('div', [], {'class': 'container', 'id': 'updated'});
      final mutations = reconciler.diff(oldTree, newTree);

      expect(mutations.length, 1);
      final mutation = mutations.first as UpdateMutation;
      expect(mutation.path, isEmpty);
      expect(mutation.attributeChanges, equals({'id': 'updated'}));
    });

    test('children insert/delete produces correct child path mutations', () {
      const oldTree = Component.element('div', [
        Component.text('Item 1'),
      ], {});

      const newTree = Component.element('div', [
        Component.text('Item 1'),
        Component.text('Item 2'),
      ], {});

      final mutations = reconciler.diff(oldTree, newTree);

      expect(mutations.length, 1);
      expect(
        mutations.first,
        equals(const InsertMutation([1], Component.text('Item 2'))),
      );
    });

    test('fragment reconciliation diffs children', () {
      const oldTree = Component.fragment([
        Component.text('A'),
        Component.text('B'),
      ]);
      const newTree = Component.fragment([
        Component.text('A'),
        Component.text('C'),
      ]);

      final mutations = reconciler.diff(oldTree, newTree);
      expect(mutations.length, 1);
      expect(
        mutations.first,
        equals(const UpdateMutation(
          path: [1],
          oldComponent: Component.text('B'),
          newComponent: Component.text('C'),
        )),
      );
    });
  });
}
