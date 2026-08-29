import 'package:bloc_signals/bloc_signals.dart';
import '../framework/framework.dart';

/// A component that re-renders itself when an underlying [BlocSignalBase] updates.
abstract class SignalComponent extends Component {
  const SignalComponent();

  /// Implement this method to construct the component tree reactively.
  Component buildSignal(SignalContext context);

  @override
  Iterable<Component> build() {
    final ctx = SignalContext.of(this);
    return [ctx.watch(buildSignal)];
  }
}

/// A reactive context for SignalComponent nodes that manages subscriptions to [BlocSignalBase] containers
/// and retains lifecycle across rebuilds to trigger targeted sub-tree reconciliation when state updates occur.
class SignalContext {
  static final Expando<SignalContext> _contextMap = Expando<SignalContext>('SignalContext');

  /// Gets or creates a persistent [SignalContext] tied to [component]'s object identity.
  factory SignalContext.of(Component component) {
    return _contextMap[component] ??= SignalContext._();
  }

  SignalContext._();
  SignalContext();

  final List<void Function()> _disposers = [];
  final Set<BlocSignalBase> _observedBlocs = {};
  Component? _lastTree;
  bool _isBuilding = false;
  void Function(List<RenderMutation> mutations)? onReconcile;
  final Reconciler _reconciler = const Reconciler();
  Component Function(SignalContext context)? _currentBuilder;

  /// Observes a [BlocSignalBase] state container and returns its current state.
  /// Automatically registers a listener to trigger sub-tree reconciliation when the state changes.
  S observe<S>(BlocSignalBase<S> blocSignal) {
    if (!_observedBlocs.contains(blocSignal)) {
      _observedBlocs.add(blocSignal);
      final dispose = blocSignal.state.subscribe((_) {
        if (!_isBuilding && _lastTree != null) {
          rebuild();
        }
      });
      _disposers.add(dispose);
    }
    return blocSignal.stateValue;
  }

  /// Executes [builder] and sets up subscription context.
  Component watch(Component Function(SignalContext context) builder) {
    _currentBuilder = builder;
    _isBuilding = true;
    try {
      final newTree = builder(this);
      _lastTree = newTree;
      return newTree;
    } finally {
      _isBuilding = false;
    }
  }

  /// Triggers a rebuild of the sub-tree and notifies [onReconcile].
  void rebuild() {
    final builder = _currentBuilder;
    if (builder != null) {
      _isBuilding = true;
      try {
        final newTree = builder(this);
        if (_lastTree != null && onReconcile != null) {
          final mutations = _reconciler.diff(_lastTree, newTree);
          if (mutations.isNotEmpty) {
            onReconcile!(mutations);
          }
        }
        _lastTree = newTree;
      } finally {
        _isBuilding = false;
      }
    }
  }

  /// Disposes all signal subscriptions for this context node.
  void dispose() {
    for (final dispose in _disposers) {
      dispose();
    }
    _disposers.clear();
    _observedBlocs.clear();
  }
}

/// A helper class for reactive component creation.
class ReactiveComponent extends SignalComponent {
  final Component Function(SignalContext context) builder;

  const ReactiveComponent(this.builder);

  @override
  Component buildSignal(SignalContext context) {
    return builder(context);
  }
}
