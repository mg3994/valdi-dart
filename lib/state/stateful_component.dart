import 'package:bloc_signals/bloc_signals.dart';
import 'package:signals_core/signals_core.dart';
import '../framework/framework.dart';
import '../reconciler/reconciler.dart';

/// Callback type for rendering stateful components.
typedef SignalComponentBuilder<T> = Component Function(T state);

/// A stateful component wrapper that integrates `bloc_signals` & `signals_core`.
///
/// Subscribes to a `ReadonlySignal<T>` or [BlocSignalBase] and triggers localized
/// reconciliation when the signal state changes.
class SignalComponent<T> extends Component {
  final ReadonlySignal<T> signal;
  final SignalComponentBuilder<T> builder;

  SignalComponent({
    required this.signal,
    required this.builder,
  }) : super();

  /// Holds the current rendered subtree produced by this component.
  Component? _currentTree;
  void Function()? _unsubscribe;
  void Function(List<MutationOp> ops)? _onReconcile;

  /// Mounts the component, building the subtree and setting up signal listener.
  Component mount({void Function(List<MutationOp> ops)? onReconcile}) {
    _onReconcile = onReconcile;
    _currentTree = builder(signal.value);

    // Subscribe to signal changes for targeted re-evaluation
    _unsubscribe?.call();
    _unsubscribe = signal.subscribe((newState) {
      _reconcile(newState);
    });

    return _currentTree!;
  }

  /// Triggers a localized rebuild & reconciliation when signal updates.
  void _reconcile(T newState) {
    final newTree = builder(newState);
    if (_currentTree != null) {
      final reconciler = Reconciler();
      final ops = reconciler.diff(_currentTree, newTree);
      _currentTree = newTree;
      if (_onReconcile != null && ops.isNotEmpty) {
        _onReconcile!(ops);
      }
    } else {
      _currentTree = newTree;
    }
  }

  /// Cleans up subscriptions on disposal.
  void dispose() {
    _unsubscribe?.call();
    _unsubscribe = null;
  }

  @override
  Iterable<Component> build() {
    _currentTree ??= builder(signal.value);
    return [_currentTree!];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SignalComponent<T> &&
        other.signal == signal &&
        other._currentTree == _currentTree;
  }

  @override
  int get hashCode => Object.hash(signal, _currentTree);
}

/// Abstract base class for custom stateful Valdi components backed by BLoC signals.
abstract class StatefulComponent<State> extends Component {
  final CubitSignal<State> cubit;

  StatefulComponent(this.cubit);

  Component buildState(State state);

  @override
  Iterable<Component> build() {
    return [
      SignalComponent<State>(
        signal: cubit.state,
        builder: buildState,
      )
    ];
  }

  void dispose() {
    cubit.close();
  }
}
