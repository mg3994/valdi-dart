import 'package:test/test.dart';
import 'package:valdi_dart/components/valdi_components.dart';
import 'package:valdi_dart/framework/framework.dart';

void main() {
  group('Standard Valdi Component Library Tests', () {
    test('VStack renders with flex column layout attributes', () {
      final vstack = VStack(children: [Component.text('Item 1')]);
      expect(vstack.tag, equals('div'));
      expect(vstack.attributes['display'], equals('flex'));
      expect(vstack.attributes['flex-direction'], equals('column'));
      expect(vstack.children.length, equals(1));
    });

    test('HStack renders with flex row layout attributes', () {
      final hstack = HStack(children: [Component.text('Item 1')]);
      expect(hstack.tag, equals('div'));
      expect(hstack.attributes['display'], equals('flex'));
      expect(hstack.attributes['flex-direction'], equals('row'));
      expect(hstack.children.length, equals(1));
    });

    test('Image renders with src and alt attributes', () {
      final img = Image(src: 'https://example.com/logo.png', alt: 'Logo');
      expect(img.tag, equals('img'));
      expect(img.attributes['src'], equals('https://example.com/logo.png'));
      expect(img.attributes['alt'], equals('Logo'));
    });

    test('ScrollView renders scrollable container attributes', () {
      final scroll = ScrollView(direction: FlexDirection.column);
      expect(scroll.tag, equals('scroll-view'));
      expect(scroll.attributes['overflow'], equals('scroll'));
      expect(scroll.attributes['direction'], equals('column'));
    });

    test('Button renders click event and label child', () {
      final btn = Button(label: 'Click Me', onClick: () {});
      expect(btn.tag, equals('button'));
      expect(btn.attributes['clickable'], equals('true'));
      expect(btn.children.first, equals(Component.text('Click Me')));
    });
  });
}
