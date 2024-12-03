import 'package:bucketeer_flutter_client_sdk/src/value.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BKTValue Equality Tests', () {
    test('BKTBoolean equality', () {
      expect(const BKTBoolean(true), equals(const BKTBoolean(true)));
      expect(const BKTBoolean(false), equals(const BKTBoolean(false)));
      expect(const BKTBoolean(true), isNot(equals(const BKTBoolean(false))));
    });

    test('BKTString equality', () {
      expect(const BKTString('Hello'), equals(const BKTString('Hello')));
      expect(const BKTString('World'), equals(const BKTString('World')));
      expect(const BKTString('Hello'), isNot(equals(const BKTString('World'))));
    });

    test('BKTNumber equality', () {
      expect(const BKTNumber(42.0), equals(const BKTNumber(42.0)));
      expect(const BKTNumber(3.14), equals(const BKTNumber(3.14)));
      expect(const BKTNumber(42.0), isNot(equals(const BKTNumber(3.14))));
    });

    test('BKTList equality', () {
      expect(
        const BKTList([BKTString('Hello'), BKTNumber(42.0)]),
        equals(const BKTList([BKTString('Hello'), BKTNumber(42.0)])),
      );
      expect(
        const BKTList([BKTBoolean(true), BKTNull()]),
        equals(const BKTList([BKTBoolean(true), BKTNull()])),
      );
      expect(
        const BKTList([BKTString('Hello')]),
        isNot(equals(const BKTList([BKTString('World')]))),
      );
      expect(
        const BKTList([BKTString('Hello')]),
        isNot(equals(const BKTList([BKTString('Hello'), BKTNumber(42.0)]))),
      );
    });

    test('BKTStructure equality', () {
      expect(
        const BKTStructure(
            {'key1': BKTString('value1'), 'key2': BKTNumber(2.0)}),
        equals(const BKTStructure(
            {'key1': BKTString('value1'), 'key2': BKTNumber(2.0)})),
      );

      // Test un-order
      expect(
        const BKTStructure(
            {'key2': BKTNumber(2.0), 'key1': BKTString('value1')}),
        equals(const BKTStructure(
            {'key1': BKTString('value1'), 'key2': BKTNumber(2.0)})),
      );
      expect(
        const BKTStructure({'key1': BKTBoolean(true)}),
        equals(const BKTStructure({'key1': BKTBoolean(true)})),
      );
      expect(
        const BKTStructure({'key1': BKTString('value1')}),
        isNot(equals(const BKTStructure({'key1': BKTString('value2')}))),
      );
      expect(
        const BKTStructure({'key1': BKTString('value1')}),
        isNot(equals(const BKTStructure({'key2': BKTString('value1')}))),
      );
    });

    test('BKTNull equality', () {
      expect(const BKTNull(), equals(const BKTNull()));
      expect(const BKTNull(), isNot(equals(const BKTString('null'))));
    });
  });
}
