import '../framework/framework.dart';

/// Flex direction options for Valdi layouts.
enum FlexDirection { column, row }

/// Target native platform for view rendering mappings.
enum ValdiPlatform { android, iOS, web }

/// Helper function to cleanly merge base component attributes with user overrides (DRY principle).
Map<String, String> _mergeAttributes(Map<String, String> base, Map<String, String>? overrides) {
  if (overrides == null || overrides.isEmpty) return base;
  return {...base, ...overrides};
}

/// Helper extension to get platform-specific native view tag names.
extension NativeViewTagExtension on CustomDomComponent {
  String nativeViewTag(ValdiPlatform platform) {
    return switch ((tag, platform)) {
      ('div', ValdiPlatform.android) => 'android.widget.LinearLayout',
      ('div', ValdiPlatform.iOS) => 'UIStackView',
      ('div', ValdiPlatform.web) => 'div',
      ('img', ValdiPlatform.android) => 'android.widget.ImageView',
      ('img', ValdiPlatform.iOS) => 'UIImageView',
      ('img', ValdiPlatform.web) => 'img',
      ('scroll-view', ValdiPlatform.android) => 'android.widget.ScrollView',
      ('scroll-view', ValdiPlatform.iOS) => 'UIScrollView',
      ('scroll-view', ValdiPlatform.web) => 'div',
      ('button', ValdiPlatform.android) => 'android.widget.Button',
      ('button', ValdiPlatform.iOS) => 'UIButton',
      ('button', ValdiPlatform.web) => 'button',
      _ => tag,
    };
  }
}

/// Flex layout component for vertical arrangement.
class VStack extends CustomDomComponent<Map<String, String>, List<Component>> {
  VStack({
    List<Component>? children,
    Map<String, String>? attributes,
  }) : super(
          'div',
          _mergeAttributes(
            {'display': 'flex', 'flex-direction': 'column'},
            attributes,
          ),
          children ?? const [],
        );
}

/// Flex layout component for horizontal arrangement.
class HStack extends CustomDomComponent<Map<String, String>, List<Component>> {
  HStack({
    List<Component>? children,
    Map<String, String>? attributes,
  }) : super(
          'div',
          _mergeAttributes(
            {'display': 'flex', 'flex-direction': 'row'},
            attributes,
          ),
          children ?? const [],
        );
}

/// Image component wrapper around CustomDomComponent.
class Image extends CustomDomComponent<Map<String, String>, List<Component>> {
  final String src;
  final String? alt;

  Image({
    required this.src,
    this.alt,
    Map<String, String>? attributes,
  }) : super(
          'img',
          _mergeAttributes(
            {
              'src': src,
              if (alt != null) 'alt': alt,
            },
            attributes,
          ),
          const [],
        );
}

/// ScrollView component wrapper around CustomDomComponent.
class ScrollView extends CustomDomComponent<Map<String, String>, List<Component>> {
  final FlexDirection direction;

  ScrollView({
    List<Component>? children,
    this.direction = FlexDirection.column,
    Map<String, String>? attributes,
  }) : super(
          'scroll-view',
          _mergeAttributes(
            {
              'overflow': 'scroll',
              'direction': direction.name,
            },
            attributes,
          ),
          children ?? const [],
        );
}

/// Button component wrapper around CustomDomComponent.
class Button extends CustomDomComponent<Map<String, String>, List<Component>> {
  final String? label;
  final void Function()? onClick;

  Button({
    this.label,
    this.onClick,
    List<Component>? children,
    Map<String, String>? attributes,
  }) : super(
          'button',
          _mergeAttributes(
            {
              if (onClick != null) 'clickable': 'true',
            },
            attributes,
          ),
          [
            if (label != null) Component.text(label),
            ...?children,
          ],
        );

  /// Dispatches click interaction to callback handler.
  void click() {
    onClick?.call();
  }
}
