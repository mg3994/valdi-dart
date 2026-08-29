import 'package:test/test.dart';
import 'package:valdi_dart/valdi_dart.dart';

void main() {
  group('Component foundational tests', () {
    test('Text component', () {
      const text = Component.text('valdi');
      expect(text, equals(const Text('valdi')));
    });
  });
}
