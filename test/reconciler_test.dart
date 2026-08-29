import 'package:test/test.dart';
import 'package:valdi_dart/framework/framework.dart';
import 'package:valdi_dart/reconciler/reconciler.dart';

void main() {
  late Reconciler reconciler;

  setUp(() {
    reconciler = Reconciler();
  });

  group('Reconciler diffing engine tests', () {
    test('Identical component trees yield no mutation ops', () {
      final oldTree = Component.element('div', [Component.text('Hello')], {'class': 'container'});
      final newTree = Component.element('div', [Component.text('Hello')], {'class': 'container'});

      final ops = reconciler.diff(oldTree, newTree);
      expect(ops, isEmpty);
    });

    test('Attribute updates generate UpdateOp', () {
      final oldTree = Component.element('div', [], {'color': 'red'});
      final newTree = Component.element('div', [], {'color': 'blue'});

      final ops = reconciler.diff(oldTree, newTree);
      expect(ops.length, equals(1));
      expect(ops.first, isA<UpdateOp>());
      final update = ops.first as UpdateOp;
      expect(update.attributeChanges['color'], equals('blue'));
    });

    test('Text content updates generate UpdateOp', () {
      final oldTree = Component.text('Old Text');
      final newTree = Component.text('New Text');

      final ops = reconciler.diff(oldTree, newTree);
      expect(ops.length, equals(1));
      expect(ops.first, isA<UpdateOp>());
      final update = ops.first as UpdateOp;
      expect((update.newComponent as Text).value, equals('New Text'));
    });

    test('Child addition generates InsertOp', () {
      final oldTree = Component.element('div', [Component.text('First')], {});
      final newTree = Component.element('div', [Component.text('First'), Component.text('Second')], {});

      final ops = reconciler.diff(oldTree, newTree);
      expect(ops.length, equals(1));
      expect(ops.first, isA<InsertOp>());
      final insert = ops.first as InsertOp;
      expect(insert.index, equals(1));
      expect((insert.component as Text).value, equals('Second'));
    });

    test('Child removal generates DeleteOp', () {
      final oldTree = Component.element('div', [Component.text('First'), Component.text('Second')], {});
      final newTree = Component.element('div', [Component.text('First')], {});

      final ops = reconciler.diff(oldTree, newTree);
      expect(ops.length, equals(1));
      expect(ops.first, isA<DeleteOp>());
      final delete = ops.first as DeleteOp;
      expect(delete.index, equals(1));
    });
  });
}
