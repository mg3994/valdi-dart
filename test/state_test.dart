import 'package:bloc_signals/bloc_signals.dart';
import 'package:test/test.dart';
import 'package:valdi_dart/framework/framework.dart';
import 'package:valdi_dart/reconciler/reconciler.dart';
import 'package:valdi_dart/state/stateful_component.dart';

class CounterCubit extends CubitSignal<int> {
  CounterCubit() : super(initialState: 0);

  void increment() => emit(stateValue + 1);
  void decrement() => emit(stateValue - 1);
}

void main() {
  group('State Management Bridge (bloc_signals) Tests', () {
    test('SignalComponent mounts and builds initial component', () {
      final counter = CounterCubit();
      final signalComp = SignalComponent<int>(
        signal: counter.state,
        builder: (count) => Component.text('Count: $count'),
      );

      final initialTree = signalComp.mount();
      expect(initialTree, equals(Component.text('Count: 0')));
      signalComp.dispose();
      counter.close();
    });

    test('Signal state update triggers localized targeted reconciliation', () {
      final counter = CounterCubit();
      final mutationOpsLog = <List<MutationOp>>[];

      final signalComp = SignalComponent<int>(
        signal: counter.state,
        builder: (count) => Component.text('Count: $count'),
      );

      signalComp.mount(onReconcile: (ops) {
        mutationOpsLog.add(ops);
      });

      // Mutate signal state
      counter.increment();

      expect(mutationOpsLog.length, equals(1));
      final ops = mutationOpsLog.first;
      expect(ops.length, equals(1));
      expect(ops.first, isA<UpdateOp>());
      final update = ops.first as UpdateOp;
      expect((update.newComponent as Text).value, equals('Count: 1'));

      signalComp.dispose();
      counter.close();
    });
  });
}
