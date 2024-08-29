import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BKTValue.fromJson', () {
    // Basic tests as shown earlier
    test('should return BKTString when given a string', () {
      var result = BKTValue.fromJson("test");
      expect(result, isA<BKTString>());
      expect((result as BKTString).value, equals("test"));

      expect((result).asDouble(), equals(null));
      expect((result).asInteger(), equals(null));

      expect((result).asBoolean(), equals(null));
      expect((result).asList(), equals(null));
      expect((result).asDictionary(), equals(null));
      expect((result).asString(), equals("test"));

      var result2 = BKTValue.fromJson("null");
      expect(result2, isA<BKTString>());
      expect((result2 as BKTString).value, equals("null"));

      var result3 = BKTValue.fromJson("true");
      expect(result3, isA<BKTString>());
      expect((result3 as BKTString).value, equals("true"));

    });

    test('should return BKTNumber when given a num', () {
      var result = BKTValue.fromJson(42.2);
      expect(result, isA<BKTNumber>());
      expect((result as BKTNumber).value, equals(42.2));

      expect((result).asDouble(), equals(42.2));
      expect((result).asInteger(), equals(42));

      expect((result).asBoolean(), equals(null));
      expect((result).asList(), equals(null));
      expect((result).asDictionary(), equals(null));
      expect((result).asString(), equals(null));
    });

    test('should return BKTBoolean when given a boolean', () {
      var result = BKTValue.fromJson(true);
      expect(result, isA<BKTBoolean>());

      expect((result).asDouble(), equals(null));
      expect((result).asInteger(), equals(null));

      expect((result).asBoolean(), equals(true));
      expect((result).asList(), equals(null));
      expect((result).asDictionary(), equals(null));
      expect((result).asString(), equals(null));
    });

    test('should return BKTList with correct elements when given a list', () {
      var json = [1, "test", true, null];
      var result = BKTValue.fromJson(json);

      // Check that the result is a BKTList
      expect(result, isA<BKTList>());

      // Check the contents of the list
      var list = result as BKTList;
      expect(list.value.length, equals(4));

      expect(list.value[0], isA<BKTNumber>());
      expect((list.value[0] as BKTNumber).value, equals(1.0));

      expect(list.value[1], isA<BKTString>());
      expect((list.value[1] as BKTString).value, equals("test"));

      expect(list.value[2], isA<BKTBoolean>());
      expect((list.value[2] as BKTBoolean).value, equals(true));

      expect(list.value[3], isA<BKTNull>());


      expect((result).asDouble(), equals(null));
      expect((result).asInteger(), equals(null));

      expect((result).asBoolean(), equals(null));
      expect((result).asDictionary(), equals(null));
      expect((result).asString(), equals(null));
    });

    test('should return BKTStructure when given a map', () {
      var result = BKTValue.fromJson({"key": "value"});
      expect(result, isA<BKTStructure>());

      expect((result).asDouble(), equals(null));
      expect((result).asInteger(), equals(null));

      expect((result).asBoolean(), equals(null));
      expect((result).asList(), equals(null));
      expect((result).asString(), equals(null));
    });

    test('should return BKTNull when given null', () {
      var result = BKTValue.fromJson(null);
      expect(result, isA<BKTNull>());
    });

    test('should throw FormatException for unsupported types', () {
      expect(() => BKTValue.fromJson(DateTime.now()), throwsFormatException);
    });

    // Complex test case
    test('should correctly parse a complex BKTStructure', () {
      var json = {
        "string": "hello",
        "number": 123,
        "boolean": false,
        "list": [1, "test", null],
        "structure": {
          "innerString": "world",
          "innerNumber": 456.78,
          "innerBoolean": true,
        },
        "nullValue": null
      };

      var result = BKTValue.fromJson(json);
      expect(result, isA<BKTStructure>());

      var structure = result as BKTStructure;
      expect(structure.value['string'], isA<BKTString>());
      expect(structure.value['number'], isA<BKTNumber>());
      expect(structure.value['boolean'], isA<BKTBoolean>());
      expect(structure.value['list'], isA<BKTList>());
      expect(structure.value['structure'], isA<BKTStructure>());
      expect(structure.value['nullValue'], isA<BKTNull>());

      var innerStructure = structure.value['structure'] as BKTStructure;
      expect(innerStructure.value['innerString'], isA<BKTString>());
      expect(innerStructure.value['innerNumber'], isA<BKTNumber>());
      expect(innerStructure.value['innerBoolean'], isA<BKTBoolean>());
    });
  });
}