import 'package:valdi_dart/valdi_dart.dart';
import 'package:bloc_signals/bloc_signals.dart';
import 'package:kaisel_core/kaisel_core.dart';

// 1. Define Application Routes using kaisel_core
sealed class AppRoute extends KaiselRoute {
  const AppRoute();
}

final class HomeScreenRoute extends AppRoute {
  const HomeScreenRoute();
}

final class DetailsScreenRoute extends AppRoute {
  final int counterValue;
  const DetailsScreenRoute(this.counterValue);

  @override
  List<Object?> get props => [counterValue];
}

// 2. Define State using bloc_signals
class CounterCubit extends CubitSignal<int> {
  CounterCubit() : super(initialState: 0);

  void increment() => emit(stateValue + 1);
  void decrement() => emit(stateValue - 1);
}

// 3. Define UI Components using Valdi Component tree primitives
class CounterView extends SignalComponent {
  final CounterCubit counterCubit;
  final AppRouter<AppRoute> router;

  const CounterView({required this.counterCubit, required this.router});

  @override
  Component buildSignal(SignalContext context) {
    final count = context.observe(counterCubit);

    return VStack(
      spacing: '16px',
      alignment: 'center',
      children: [
        Component.text('Valdi Dart Native Framework Demo'),
        Component.text('Current Counter Value: $count'),
        HStack(
          spacing: '8px',
          children: [
            Button(
              child: const Component.text('+ Increment'),
              onClickEventId: 'increment_action',
            ),
            Button(
              child: const Component.text('- Decrement'),
              onClickEventId: 'decrement_action',
            ),
          ],
        ),
        Button(
          child: const Component.text('Go to Details Screen ->'),
          onClickEventId: 'navigate_details_action',
        ),
      ],
    );
  }
}

class DetailsView extends Component {
  final int count;
  final AppRouter<AppRoute> router;

  const DetailsView({required this.count, required this.router});

  @override
  Iterable<Component> build() {
    return [
      VStack(
        spacing: '20px',
        alignment: 'center',
        children: [
          const Component.text('Details Screen'),
          Component.text('Passed Counter Value: $count'),
          Button(
            child: const Component.text('<- Back to Home'),
            onClickEventId: 'navigate_back_action',
          ),
        ],
      )
    ];
  }
}

void main() async {
  print('=== Valdi-Dart Native Multi-Platform Rendering Framework Demo ===\n');

  final counterCubit = CounterCubit();
  final router = AppRouter<AppRoute>(initialRoute: const HomeScreenRoute());
  final renderDriver = DefaultNativeRenderDriver();

  // Register route mappings
  router.registerRoute<HomeScreenRoute>((route) {
    return CounterView(counterCubit: counterCubit, router: router);
  });

  router.registerRoute<DetailsScreenRoute>((route) {
    return DetailsView(count: route.counterValue, router: router);
  });

  final signalContext = SignalContext();

  // Watch tree rendering & state changes
  Component currentTree = signalContext.watch((ctx) => router.buildCurrentTree());

  // Mount initial component tree to native view hierarchy (Android View / iOS UIView / Impeller)
  final nativeViewTree = renderDriver.mount(currentTree);
  print('Mounted Native View Hierarchy (Android/iOS/Flutter Native):');
  print('  $nativeViewTree');

  signalContext.onReconcile = (mutations) {
    print('\n[Reconciler] Applying sub-tree mutations to Native Views:');
    for (final mutation in mutations) {
      print('  -> $mutation');
    }
    renderDriver.applyMutations(nativeViewTree, mutations);
  };

  // 1. Mutate State
  print('\n---> Action: Incrementing counter...');
  counterCubit.increment();

  currentTree = router.buildCurrentTree();
  print('\nNative View Tree after Increment:');
  print('  $nativeViewTree');

  // 2. Navigate to Details Screen
  print('\n---> Action: Navigating to Details Screen...');
  await router.push(DetailsScreenRoute(counterCubit.stateValue));

  currentTree = router.buildCurrentTree();
  print('\nRender Tree at Details Screen:');
  _printComponentTree(currentTree, 0);

  // 3. Navigate back
  print('\n---> Action: Navigating back to Home Screen...');
  await router.pop();

  currentTree = router.buildCurrentTree();
  print('\nRender Tree back at Home Screen:');
  _printComponentTree(currentTree, 0);

  // Cleanup
  signalContext.dispose();
  counterCubit.close();

  print('\n=== Valdi Native Framework Demo Executed Successfully! ===');
}

void _printComponentTree(Component component, int indentLevel) {
  final indent = '  ' * indentLevel;
  if (component is Text) {
    print('$indent- Text("${component.value}", escape: ${component.escape})');
  } else if (component is DomComponent) {
    print('$indent- Element <${component.tag}> attrs: ${component.attributes}');
    for (final child in component.children) {
      _printComponentTree(child, indentLevel + 1);
    }
  } else if (component is Fragment) {
    print('$indent- Fragment');
    for (final child in component.children) {
      _printComponentTree(child, indentLevel + 1);
    }
  } else if (component is SignalComponent) {
    final built = component.build().first;
    _printComponentTree(built, indentLevel);
  } else {
    print('$indent- Component: ${component.runtimeType}');
  }
}
