import 'package:valdi_dart/valdi_dart.dart';

void main() {
  const component = Component.text('Hello Valdi');
  print((component as Text).value);
}
