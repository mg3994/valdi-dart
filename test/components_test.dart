import 'package:test/test.dart';
import 'package:valdi_dart/valdi_dart.dart';

void main() {
  group('Standard Valdi Component Library Tests', () {
    test('VStack component attributes and children', () {
      final vstack = VStack(
        alignment: 'center',
        spacing: '10px',
        children: [
          const Component.text('Item 1'),
          const Component.text('Item 2'),
        ],
      );

      expect(vstack.tag, equals('vstack'));
      expect(
        vstack.attributes,
        equals({
          'valdi-type': 'VStack',
          'flex-direction': 'column',
          'align-items': 'center',
          'gap': '10px',
        }),
      );
      expect(vstack.children.length, equals(2));
    });

    test('HStack component attributes and children', () {
      final hstack = HStack(
        alignment: 'flex-start',
        children: [const Component.text('Left'), const Component.text('Right')],
      );

      expect(hstack.tag, equals('hstack'));
      expect(
        hstack.attributes,
        equals({
          'valdi-type': 'HStack',
          'flex-direction': 'row',
          'align-items': 'flex-start',
        }),
      );
    });

    test('Image component attributes', () {
      final image = Image(src: 'https://example.com/logo.png', width: 100, height: 100);
      expect(image.tag, equals('img'));
      expect(
        image.attributes,
        equals({
          'valdi-type': 'Image',
          'src': 'https://example.com/logo.png',
          'width': '100.0',
          'height': '100.0',
        }),
      );
      expect(image.children, isEmpty);
    });

    test('ScrollView component attributes', () {
      final scroll = ScrollView(
        children: [const Component.text('Scrolled content')],
      );
      expect(scroll.tag, equals('scrollview'));
      expect(
        scroll.attributes,
        equals({
          'valdi-type': 'ScrollView',
          'scroll-direction': 'vertical',
          'overflow': 'auto',
        }),
      );
    });

    test('Button component attributes and child', () {
      final button = Button(
        child: const Component.text('Click me'),
        onClickEventId: 'evt_123',
      );

      expect(button.tag, equals('button'));
      expect(
        button.attributes,
        equals({
          'valdi-type': 'Button',
          'onclick': 'evt_123',
        }),
      );
      expect(button.children.first, equals(const Component.text('Click me')));
    });
  });
}
