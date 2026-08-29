import 'package:bloc_signals/bloc_signals.dart';
import 'package:valdi_dart/valdi_dart.dart';

/// Counter state container using bloc_signals.
class CounterCubit extends CubitSignal<int> {
  CounterCubit() : super(initialState: 0);

  void increment() => emit(stateValue + 1);
  void decrement() => emit(stateValue - 1);
}

/// Global router instance and state cubit for the example application.
final CounterCubit counterCubit = CounterCubit();

late final AppRoute homeRoute;
late final AppRoute detailsRoute;
late final AppRouter appRouter;

void main() {
  print('=== Starting Valdi-Dart Application ===');

  homeRoute = AppRoute('/home', buildHomeScreen);
  detailsRoute = AppRoute('/details', buildDetailsScreen);
  appRouter = AppRouter(initialRoute: homeRoute);

  // Render initial route across target native platforms
  printCurrentState();

  // Listen for navigation changes
  appRouter.addListener(() {
    print('\n[Router] Navigation event occurred!');
    printCurrentState();
  });

  // Perform state update on Home Screen
  print('\n---> User clicks Increment Counter button');
  counterCubit.increment();

  // Navigate to Details screen using kaisel_core router
  print('\n---> User navigates to Details Screen');
  appRouter.push(detailsRoute);

  // Perform state update on Details Screen
  print('\n---> User clicks Increment Counter button on Details Screen');
  counterCubit.increment();

  // Navigate back to Home screen using kaisel_core router
  print('\n---> User navigates back to Home Screen');
  appRouter.pop();

  print('\n=== Valdi-Dart Application Run Finished ===');
}

Component buildHomeScreen() {
  return VStack(
    children: [
      Component.text('--- Home Screen ---'),
      Image(src: 'https://valdi.dev/logo.png', alt: 'Valdi Logo'),
      SignalComponent<int>(
        signal: counterCubit.state,
        builder: (count) => Component.text('Current Counter: $count'),
      ),
      Button(
        label: 'Increment Counter',
        onClick: () => counterCubit.increment(),
      ),
      Button(
        label: 'Go to Details Screen',
        onClick: () => appRouter.push(detailsRoute),
      ),
    ],
  );
}

Component buildDetailsScreen() {
  return ScrollView(
    children: [
      VStack(
        children: [
          Component.text('--- Details Screen ---'),
          SignalComponent<int>(
            signal: counterCubit.state,
            builder: (count) => Component.text('Counter value on details: $count'),
          ),
          Button(
            label: 'Increment Counter',
            onClick: () => counterCubit.increment(),
          ),
          Button(
            label: 'Back to Home',
            onClick: () => appRouter.pop(),
          ),
        ],
      ),
    ],
  );
}

void printCurrentState() {
  final currentRoute = appRouter.currentRoute;
  final componentTree = appRouter.buildCurrentComponent();
  print('Active Route: ${currentRoute.id}');
  print('Rendered Component Tree: $componentTree');
  if (componentTree is CustomDomComponent) {
    print('Native View Mapping (Android): ${componentTree.nativeViewTag(ValdiPlatform.android)}');
    print('Native View Mapping (iOS): ${componentTree.nativeViewTag(ValdiPlatform.iOS)}');
    print('Native View Mapping (Web): ${componentTree.nativeViewTag(ValdiPlatform.web)}');
  }
}
