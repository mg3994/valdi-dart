import 'package:kaisel_core/kaisel_core.dart';
import '../framework/framework.dart';

/// Typed builder function mapping a route to a component tree.
typedef RouteComponentBuilder<R extends KaiselRoute> = Component Function(R route);

/// AppRouter wraps `kaisel_core` navigation paradigms and maps defined routes to Valdi [Component] trees.
class AppRouter<R extends KaiselRoute> {
  final KaiselRouter<R> kaiselRouter;
  final Map<Type, RouteComponentBuilder<R>> _routeBuilders = {};

  AppRouter({
    required R initialRoute,
    List<KaiselGuard<R>> guards = const [],
  }) : kaiselRouter = KaiselRouter<R>(
          initial: initialRoute,
          guards: guards,
        );

  /// Registers a component builder for a specific route type [T].
  void registerRoute<T extends R>(Component Function(T route) builder) {
    _routeBuilders[T] = (R route) => builder(route as T);
  }

  /// Pushes a new route onto the navigation stack.
  Future<void> push(R route) => kaiselRouter.push(route);

  /// Pops the current route off the stack.
  Future<bool> pop() => kaiselRouter.pop();

  /// Replaces top route with a new route.
  Future<void> replaceTop(R route) => kaiselRouter.replaceTop(route);

  /// Runs a modal presentation flow, returning a result of type [M].
  Future<M?> presentModal<M>(KaiselModalRoute<M> modalRoute) {
    return kaiselRouter.run<M>(modalRoute);
  }

  /// Dismisses or completes a modal flow with optional result.
  void dismissModal<M>([M? result]) {
    kaiselRouter.completeFlow<M>(result);
  }

  /// Builds the [Component] tree for the current top route in the navigation stack.
  Component buildCurrentTree() {
    final currentRoute = kaiselRouter.stack.last;
    final builder = _routeBuilders[currentRoute.runtimeType];
    if (builder != null) {
      return builder(currentRoute);
    }
    return Component.text('Route not found: ${currentRoute.runtimeType}');
  }

  /// Listens to navigation stack changes.
  void addListener(void Function() listener) {
    kaiselRouter.addListener(listener);
  }

  /// Removes listener.
  void removeListener(void Function() listener) {
    kaiselRouter.removeListener(listener);
  }
}
