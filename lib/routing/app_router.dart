import 'package:kaisel_core/kaisel_core.dart';
import '../framework/framework.dart';

/// Base class for defining routes in Valdi-Dart application.
abstract class ValdiRoute extends KaiselRoute {
  const ValdiRoute();

  /// Unique identifier or path for the route.
  String get id;

  /// Returns the component tree corresponding to this route.
  Component buildComponent();
}

/// A standard route definition mapping path to a Valdi component builder.
class AppRoute extends ValdiRoute {
  final String path;
  final Component Function() builder;

  const AppRoute(this.path, this.builder);

  @override
  String get id => path;

  @override
  Component buildComponent() => builder();

  @override
  List<Object?> get props => [path];
}

/// Modal route definition for modal presentation screens.
class AppModalRoute<T> extends KaiselModalRoute<T> implements ValdiRoute {
  final String name;
  final Component Function() builder;

  const AppModalRoute(this.name, this.builder);

  @override
  String get id => name;

  @override
  Component buildComponent() => builder();

  @override
  List<Object?> get props => [name];
}

/// Main application router wrapping `kaisel_core`'s [KaiselRouter].
class AppRouter {
  final KaiselRouter<ValdiRoute> kaiselRouter;

  AppRouter({required ValdiRoute initialRoute})
      : kaiselRouter = KaiselRouter<ValdiRoute>(initial: initialRoute);

  /// Current navigation stack routes.
  List<ValdiRoute> get stack => kaiselRouter.stack;

  /// Topmost active route on the stack.
  ValdiRoute get currentRoute => kaiselRouter.stack.last;

  /// Builds the component for the current route.
  Component buildCurrentComponent() {
    return currentRoute.buildComponent();
  }

  /// Pushes a new route onto the navigation stack.
  Future<void> push(ValdiRoute route) async {
    await kaiselRouter.push(route);
  }

  /// Pops the topmost route from the navigation stack.
  Future<bool> pop() async {
    return await kaiselRouter.pop();
  }

  /// Replaces top route with a new route.
  Future<void> replace(ValdiRoute route) async {
    await kaiselRouter.replaceTop(route);
  }

  /// Presents a modal route flow.
  Future<T?> presentModal<T>(AppModalRoute<T> modalRoute) async {
    return await kaiselRouter.run<T>(modalRoute);
  }

  /// Dismisses active modal route.
  void dismissModal<T>([T? result]) {
    kaiselRouter.completeFlow<T>(result);
  }

  /// Listens to navigation stack changes.
  void addListener(void Function() listener) {
    kaiselRouter.addListener(listener);
  }

  /// Removes navigation stack listener.
  void removeListener(void Function() listener) {
    kaiselRouter.removeListener(listener);
  }

  void dispose() {
    kaiselRouter.dispose();
  }
}
