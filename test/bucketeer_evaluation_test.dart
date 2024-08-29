import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BKTEvaluationDetails equality', () {
    test('Test BKTEvaluationDetails<Map<String, dynamic>> equality', () {
      final inputMap = {
        'id': 'id123',
        'featureId': 'featureId123',
        'featureVersion': 123,
        'enable': true,
      };

      expect(
          mapEquals(inputMap, {
            'id': 'id123',
            'featureId': 'featureId123',
            'featureVersion': 123,
            'enable': true,
          }),
          true,
          reason: "should match");

      final input = BKTEvaluationDetails<Map<String, dynamic>>(
        featureId: 'jsonVariation',
        featureVersion: 123,
        userId: 'userId123',
        variationId: 'variationId123',
        variationName: 'variationName123',
        variationValue: inputMap,
        reason: "DEFAULT",
      );

      expect(
          input,
          equals(
            BKTEvaluationDetails.fromJson<Map<String, dynamic>>(
              {
                'featureId': 'jsonVariation',
                'featureVersion': 123,
                'userId': 'userId123',
                'variationId': 'variationId123',
                'variationName': 'variationName123',
                'variationValue': {
                  'id': 'id123',
                  'featureId': 'featureId123',
                  'featureVersion': 123,
                  'enable': true,
                },
                'reason': "DEFAULT"
              },
            ),
          ),
          reason: "should match");

      expect(
          const BKTEvaluationDetails<Map<String, dynamic>>(
            featureId: 'jsonVariation',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: {},
            reason: "DEFAULT",
          ),
          isNot(
            equals(BKTEvaluationDetails.fromJson<double>(
              {
                'featureId': 'jsonVariation',
                'featureVersion': 123,
                'userId': 'userId123',
                'variationId': 'variationId123',
                'variationName': 'variationName123',
                'variationValue': 3.0,
                'reason': "DEFAULT"
              },
            )),
          ),
          reason: "should match");
    });

    test('Test BKTEvaluationDetails<int> equality', () {
      expect(
          const BKTEvaluationDetails<int>(
            featureId: 'jsonVariation',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: 12,
            reason: "DEFAULT",
          ),
          equals(
            BKTEvaluationDetails.fromJson<int>(
              {
                'featureId': 'jsonVariation',
                'featureVersion': 123,
                'userId': 'userId123',
                'variationId': 'variationId123',
                'variationName': 'variationName123',
                'variationValue': 12,
                'reason': "DEFAULT"
              },
            ),
          ),
          reason: "should match");

      expect(
          const BKTEvaluationDetails<int>(
            featureId: 'jsonVariation',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: 12,
            reason: "DEFAULT",
          ),
          isNot(
            BKTEvaluationDetails.fromJson<int>(
              {
                'featureId': 'jsonVariation',
                'featureVersion': 123,
                'userId': 'userId123',
                'variationId': 'variationId123',
                'variationName': 'variationName123',
                'variationValue': 123,
                'reason': "DEFAULT"
              },
            ),
          ),
          reason: "should match");

      expect(
          const BKTEvaluationDetails<int>(
            featureId: 'jsonVariation',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: 12,
            reason: "DEFAULT",
          ),
          isNot(
            BKTEvaluationDetails.fromJson<int>(
              {
                'featureId': 'jsonVariation1',
                'featureVersion': 123,
                'userId': 'userId123',
                'variationId': 'variationId123',
                'variationName': 'variationName123',
                'variationValue': 123,
                'reason': "DEFAULT"
              },
            ),
          ),
          reason: "should match");
    });

    test('Test BKTEvaluationDetails<bool> equality', () {
      expect(
          const BKTEvaluationDetails<bool>(
            featureId: 'jsonVariation',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: true,
            reason: "DEFAULT",
          ),
          equals(
            BKTEvaluationDetails.fromJson<bool>(
              {
                'featureId': 'jsonVariation',
                'featureVersion': 123,
                'userId': 'userId123',
                'variationId': 'variationId123',
                'variationName': 'variationName123',
                'variationValue': true,
                'reason': "DEFAULT"
              },
            ),
          ),
          reason: "should match");

      expect(
          const BKTEvaluationDetails<bool>(
            featureId: 'jsonVariation',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: true,
            reason: "DEFAULT",
          ),
          isNot(
            BKTEvaluationDetails.fromJson<bool>(
              {
                'featureId': 'jsonVariation',
                'featureVersion': 123,
                'userId': 'userId123',
                'variationId': 'variationId123',
                'variationName': 'variationName123',
                'variationValue': false,
                'reason': "DEFAULT"
              },
            ),
          ),
          reason: "should match");

      expect(
          const BKTEvaluationDetails<bool>(
            featureId: 'jsonVariation',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: true,
            reason: "DEFAULT",
          ),
          isNot(
            BKTEvaluationDetails.fromJson<bool>(
              {
                'featureId': 'jsonVariation1',
                'featureVersion': 123,
                'userId': 'userId123',
                'variationId': 'variationId123',
                'variationName': 'variationName123',
                'variationValue': true,
                'reason': "DEFAULT"
              },
            ),
          ),
          reason: "should match");
    });

    test('Test BKTEvaluationDetails<String> equality', () {
      expect(
          const BKTEvaluationDetails<String>(
            featureId: 'jsonVariation',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: "true",
            reason: "DEFAULT",
          ),
          equals(
            BKTEvaluationDetails.fromJson<String>(
              {
                'featureId': 'jsonVariation',
                'featureVersion': 123,
                'userId': 'userId123',
                'variationId': 'variationId123',
                'variationName': 'variationName123',
                'variationValue': "true",
                'reason': "DEFAULT"
              },
            ),
          ),
          reason: "should match");

      expect(
          const BKTEvaluationDetails<String>(
            featureId: 'jsonVariation',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: "true",
            reason: "DEFAULT",
          ),
          isNot(
            BKTEvaluationDetails.fromJson<String>(
              {
                'featureId': 'jsonVariation',
                'featureVersion': 123,
                'userId': 'userId123',
                'variationId': 'variationId123',
                'variationName': 'variationName123',
                'variationValue': "false",
                'reason': "DEFAULT"
              },
            ),
          ),
          reason: "should match");

      expect(
          const BKTEvaluationDetails<String>(
            featureId: 'jsonVariation',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: "true",
            reason: "DEFAULT",
          ),
          isNot(
            BKTEvaluationDetails.fromJson<String>(
              {
                'featureId': 'jsonVariation1',
                'featureVersion': 123,
                'userId': 'userId123',
                'variationId': 'variationId123',
                'variationName': 'variationName123',
                'variationValue': "true",
                'reason': "DEFAULT"
              },
            ),
          ),
          reason: "should match");
    });

    test('Test BKTEvaluationDetails<double> equality', () {
      expect(
          const BKTEvaluationDetails<double>(
            featureId: 'jsonVariation',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: 2.0,
            reason: "DEFAULT",
          ),
          equals(
            BKTEvaluationDetails.fromJson<double>(
              {
                'featureId': 'jsonVariation',
                'featureVersion': 123,
                'userId': 'userId123',
                'variationId': 'variationId123',
                'variationName': 'variationName123',
                'variationValue': 2.0,
                'reason': "DEFAULT"
              },
            ),
          ),
          reason: "should match");

      expect(
          const BKTEvaluationDetails<double>(
            featureId: 'jsonVariation',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: 2.0,
            reason: "DEFAULT",
          ),
          isNot(
            BKTEvaluationDetails.fromJson<double>(
              {
                'featureId': 'jsonVariation',
                'featureVersion': 123,
                'userId': 'userId123',
                'variationId': 'variationId123',
                'variationName': 'variationName123',
                'variationValue': 3.0,
                'reason': "DEFAULT"
              },
            ),
          ),
          reason: "should match");

      expect(
          const BKTEvaluationDetails<double>(
            featureId: 'jsonVariation',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: 4.0,
            reason: "DEFAULT",
          ),
          isNot(
            BKTEvaluationDetails.fromJson<double>(
              {
                'featureId': 'jsonVariation1',
                'featureVersion': 123,
                'userId': 'userId123',
                'variationId': 'variationId123',
                'variationName': 'variationName123',
                'variationValue': 4.0,
                'reason': "DEFAULT"
              },
            ),
          ),
          reason: "should match");
    });

    test('Test BKTEvaluationDetails<BKTValue> equality', () {
      expect(
          const BKTEvaluationDetails<BKTValue>(
            featureId: 'jsonVariation',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: BKTNumber(2.0),
            reason: "DEFAULT",
          ),
          equals(
            BKTEvaluationDetails.fromJson<BKTValue>(
              {
                'featureId': 'jsonVariation',
                'featureVersion': 123,
                'userId': 'userId123',
                'variationId': 'variationId123',
                'variationName': 'variationName123',
                'variationValue': 2.0,
                'reason': "DEFAULT"
              },
            ),
          ),
          reason: "should match");
    });

    expect(
        const BKTEvaluationDetails<BKTValue>(
          featureId: 'jsonVariation',
          featureVersion: 123,
          userId: 'userId123',
          variationId: 'variationId123',
          variationName: 'variationName123',
          variationValue: BKTString("true"),
          reason: "DEFAULT",
        ),
        equals(
          BKTEvaluationDetails.fromJson<BKTValue>(
            {
              'featureId': 'jsonVariation',
              'featureVersion': 123,
              'userId': 'userId123',
              'variationId': 'variationId123',
              'variationName': 'variationName123',
              'variationValue': "true",
              'reason': "DEFAULT"
            },
          ),
        ),
        reason: "should match");

    expect(
        const BKTEvaluationDetails<BKTValue>(
          featureId: 'jsonVariation',
          featureVersion: 123,
          userId: 'userId123',
          variationId: 'variationId123',
          variationName: 'variationName123',
          variationValue: BKTStructure(
            {
              'key': BKTString('value'),
              'num': BKTNumber(12.2),
            },
          ),
          reason: "DEFAULT",
        ),
        isNot(
          equals(BKTEvaluationDetails.fromJson<BKTValue>(
            {
              'featureId': 'jsonVariation',
              'featureVersion': 123,
              'userId': 'userId123',
              'variationId': 'variationId123',
              'variationName': 'variationName123',
              'variationValue': {'key': 'value', 'num': 12.2},
              'reason': "DEFAULT"
            },
          )),
        ),
        reason: "should match");
  });
}
