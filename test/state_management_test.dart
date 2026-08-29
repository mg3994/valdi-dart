import 'package:test/test.dart';
import 'package:valdi_dart/valdi_dart.dart';
import 'package:bloc_signals/bloc_signals.dart';

class CounterCubit extends CubitSignal<int> {
  CounterCubit() : super(initialState: 0);

  void increment() => emit(stateValue + 1);
}

class CounterComponent extends SignalComponent {
  final CounterCubit cubit;

  const CounterComponent(this.cubit);

  @override
  Component buildSignal(SignalContext context) {
    final count = context.observe(cubit);
    return Component.text('Count: $count');
  }
}

void main() {
  group('State Management Bridge (bloc_signals) Tests', () {
    test('SignalContext triggers targeted reconciliation on CubitSignal update', () {
      final cubit = CounterCubit();
      final comp = CounterComponent(cubit);
      final ctx = SignalContext();
      final mutationsReceived = <List<RenderMutation>>[];

      ctx.onReconcile = (mutations) {
        mutationsReceived.add(mutations);
      };

      final initialTree = ctx.watch((context) => comp.buildSignal(context));

      expect(initialTree, equals(const Component.text('Count: 0')));
      expect(mutationsReceived, isEmpty);

      // Mutate Cubit state
      cubit.increment();

      expect(mutationsReceived.length, 1);
      expect(
        mutationsReceived.first.first,
        equals(const UpdateMutation(
          path: [],
          oldComponent: Component.text('Count: 0'),
          newComponent: Component.text('Count: 1'),
        )),
      );

      // Clean up
      ctx.dispose();
      cubit.close();
    });

    test('ReactiveComponent works with SignalContext', () {
      final cubit = CounterCubit();
      final ctx = SignalContext();
      final mutationsList = <RenderMutation>[];

      ctx.onReconcile = (mutations) {
        mutationsList.addAll(mutations);
      };

      final tree = ctx.watch((c) => ReactiveComponent((context) {
            final count = context.observe(cubit);
            return Component.text('Val: $count');
          }).buildSignal(c));

      expect(tree, equals(const Component.text('Val: 0')));

      cubit.increment();

      expect(mutationsList.length, 1);
      expect(
        mutationsList.first,
        equals(const UpdateMutation(
          path: [],
          oldComponent: Component.text('Val: 0'),
          newComponent: Component.text('Val: 1'),
        )),
      );

      ctx.dispose();
      cubit.close();
    });
  });
}
