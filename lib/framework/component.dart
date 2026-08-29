import 'package:collection/collection.dart';
import '../dom/raw_text/raw_text.dart';
export '../dom/raw_text/raw_text.dart';

/// A node in the Valdi-Dart theme component tree.
abstract class Component {
  const Component();

  /// Builds this component's children.
  Iterable<Component> build();

  /// Creates a text node component.
  const factory Component.text(String value, {bool escape}) = Text;

  /// Creates a custom DOM component node.
  const factory Component.element(
    String tag,
    List<Component>? children,
    Map<String, String>? attributes,
  ) = CustomDomComponent;

  /// Groups components together without creating a DOM node.
  const factory Component.fragment([Iterable<Component> children]) = Fragment;

  /// Creates an empty component that renders nothing.
  const factory Component.empty() = Fragment.empty;
}

/// A component that produces an actual element.
abstract interface class Element extends Component {
  const Element();
  String get tag;
}

/// A DOM-like element with a tag, attributes, and child components.
/// Utilizes Dart 3 pattern matching to allow flexible positional arguments.
abstract class DomComponent<A, B> implements Element {
  final A? _first;
  final B? _second;

  const DomComponent([this._first, this._second]);

  Map<String, String> get attributes => switch ((_first, _second)) {
    (Map<String, String> a, Map<String, String> b) => {...a, ...b},
    (Map<String, String> attrs, _) => attrs,
    (_, Map<String, String> attrs) => attrs,
    _ => const {},
  };

  Iterable<Component> get children => switch ((_first, _second)) {
    (Iterable<Component> a, Iterable<Component> b) => a.followedBy(b),
    (Iterable<Component> kids, _) => kids,
    (_, Iterable<Component> kids) => kids,
    _ => const [],
  };

  @override
  Iterable<Component> build() => children;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final mapEquals = const MapEquality().equals;
    final iterableEquals = const IterableEquality().equals;

    return other is DomComponent &&
        other.tag == tag &&
        mapEquals(other.attributes, attributes) &&
        iterableEquals(other.children, children);
  }

  @override
  int get hashCode => Object.hash(
    tag,
    const MapEquality().hash(attributes),
    const IterableEquality().hash(children),
  );
}

class CustomDomComponent<A, B> extends DomComponent<A, B> {
  @override
  final String tag;
  const CustomDomComponent(this.tag, [super.first, super.second]);
}

final class Fragment implements Component {
  final Iterable<Component> children;
  const Fragment([this.children = const []]);
  const Fragment.empty() : children = const [];

  @override
  Iterable<Component> build() => children;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Fragment &&
        const IterableEquality().equals(other.children, children);
  }

  @override
  int get hashCode => const IterableEquality().hash(children);
}
