import '../framework/framework.dart';

/// Flex axis direction for layouts.
enum FlexDirection { vertical, horizontal }

/// A vertical flex container (`VStack`).
class VStack extends DomComponent<Map<String, String>, List<Component>> {
  VStack({
    List<Component> children = const [],
    String? alignment,
    String? spacing,
    Map<String, String> style = const {},
  }) : super(
          {
            'valdi-type': 'VStack',
            'flex-direction': 'column',
            ...?alignment == null ? null : {'align-items': alignment},
            ...?spacing == null ? null : {'gap': spacing},
            ...style,
          },
          children,
        );

  @override
  String get tag => 'vstack';
}

/// A horizontal flex container (`HStack`).
class HStack extends DomComponent<Map<String, String>, List<Component>> {
  HStack({
    List<Component> children = const [],
    String? alignment,
    String? spacing,
    Map<String, String> style = const {},
  }) : super(
          {
            'valdi-type': 'HStack',
            'flex-direction': 'row',
            ...?alignment == null ? null : {'align-items': alignment},
            ...?spacing == null ? null : {'gap': spacing},
            ...style,
          },
          children,
        );

  @override
  String get tag => 'hstack';
}

/// An Image component wrapper over [CustomDomComponent].
class Image extends DomComponent<Map<String, String>, List<Component>> {
  Image({
    required String src,
    String? alt,
    double? width,
    double? height,
    Map<String, String> attributes = const {},
  }) : super(
          {
            'valdi-type': 'Image',
            'src': src,
            ...?alt == null ? null : {'alt': alt},
            ...?width == null ? null : {'width': '$width'},
            ...?height == null ? null : {'height': '$height'},
            ...attributes,
          },
          const [],
        );

  @override
  String get tag => 'img';
}

/// A ScrollView container component.
class ScrollView extends DomComponent<Map<String, String>, List<Component>> {
  ScrollView({
    List<Component> children = const [],
    String scrollDirection = 'vertical',
    Map<String, String> style = const {},
  }) : super(
          {
            'valdi-type': 'ScrollView',
            'scroll-direction': scrollDirection,
            'overflow': 'auto',
            ...style,
          },
          children,
        );

  @override
  String get tag => 'scrollview';
}

/// A Button component wrapper over [CustomDomComponent].
class Button extends DomComponent<Map<String, String>, List<Component>> {
  Button({
    required Component child,
    String? onClickEventId,
    bool disabled = false,
    Map<String, String> attributes = const {},
  }) : super(
          {
            'valdi-type': 'Button',
            ...?onClickEventId == null ? null : {'onclick': onClickEventId},
            if (disabled) 'disabled': 'true',
            ...attributes,
          },
          [child],
        );

  @override
  String get tag => 'button';
}
