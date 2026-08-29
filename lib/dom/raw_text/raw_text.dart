import '../../framework/framework.dart' show Component;

/// A text node that is rendered with optional escaping.
class Text implements Component {
  final String value;
  final bool escape;

  const Text(this.value, {this.escape = true});

  @override
  Iterable<Component> build() => const [];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Text && other.value == value && other.escape == escape;
  }

  @override
  int get hashCode => Object.hash(value, escape);
}

/// A raw text node that disables escaping.
final class RawText extends Text {
  const RawText(super.value, {super.escape = false});
}
