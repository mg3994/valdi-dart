import '../framework/framework.dart';

/// Flex direction options for Valdi layouts.
enum FlexDirection { column, row }

/// Flex layout component for vertical arrangement.
class VStack extends CustomDomComponent<Map<String, String>, List<Component>> {
  VStack({
    List<Component>? children,
    Map<String, String>? attributes,
  }) : super(
          'div',
          {
            'display': 'flex',
            'flex-direction': 'column',
            ...?attributes,
          },
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
          {
            'display': 'flex',
            'flex-direction': 'row',
            ...?attributes,
          },
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
          {
            'src': src,
            if (alt != null) 'alt': alt,
            ...?attributes,
          },
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
          {
            'overflow': 'scroll',
            'direction': direction.name,
            ...?attributes,
          },
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
          {
            if (onClick != null) 'clickable': 'true',
            ...?attributes,
          },
          [
            if (label != null) Component.text(label),
            ...?children,
          ],
        );
}
