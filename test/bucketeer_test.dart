import 'package:bucketeer_flutter_client_sdk/src/proxy_evaluation_update_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:bucketeer_flutter_client_sdk/src/call_methods.dart';
import 'package:bucketeer_flutter_client_sdk/src/constants.dart';
import 'package:flutter_test/flutter_test.dart';

import 'bucketeer_listener_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(Constants.methodChannelName);

  setUp(() async {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
      var callMethod = CallMethods.values.firstWhere(
          (element) => element.name == methodCall.method,
          orElse: () => CallMethods.unknown);
      var featureId = methodCall.arguments[CallMethodParams.featureId];
      var defaultValue = methodCall.arguments[CallMethodParams.defaultValue];
      switch (callMethod) {
        case CallMethods.initialize:
        case CallMethods.updateUserAttributes:
        case CallMethods.track:
        case CallMethods.flush:
        case CallMethods.fetchEvaluations:
        case CallMethods.destroy:
          return {'status': true};
        case CallMethods.currentUser:
          return {
            'status': true,
            'response': {
              'id': 'userId123',
              'data': {'appVersion': '9.9.9', 'platform': 'iOS'}
            }
          };
        case CallMethods.stringVariation:
          return {
            'status': false,
            'errorCode': -1,
            'errorMessage':
                'should not be called, should call stringVariationDetails instead'
          };
        case CallMethods.intVariation:
          return {
            'status': false,
            'errorCode': -1,
            'errorMessage':
                'should not be called, should call intVariationDetails instead'
          };
        case CallMethods.doubleVariation:
          return {
            'status': false,
            'errorCode': -1,
            'errorMessage':
                'should not be called, should call doubleVariationDetails instead'
          };
        case CallMethods.boolVariation:
          return {
            'status': false,
            'errorCode': -1,
            'errorMessage':
                'should not be called, should call boolVariationDetails instead'
          };
        case CallMethods.objectVariation:
          return {
            'status': false,
            'errorCode': -1,
            'errorMessage':
                'should not be called, should call objectVariationDetails instead'
          };
        case CallMethods.evaluationDetails:
          return {
            'status': true,
            'response': {
              'id': 'id123',
              'featureId': 'featureId123',
              'featureVersion': 123,
              'userId': 'userId123',
              'variationId': 'variationId123',
              'variationName': 'variationName123',
              'variationValue': 'variationValue123',
              'reason': 'DEFAULT',
            }
          };
        case CallMethods.jsonVariation:
          expect(featureId, 'jsonVariation', reason: "featureId is not match");
          expect(defaultValue is Map && mapEquals(defaultValue, {}), true,
              reason: "defaultValue is not match");
          return {
            'status': true,
            'response': {
              'id': 'id123',
              'featureId': 'featureId123',
              'featureVersion': 123,
              'enable': true
            }
          };
        case CallMethods.addProxyEvaluationUpdateListener:
          return {
            'status': true,
            'response': '00673eaf-364f-49a7-84cb-b4d723a6ac5d'
          };
        case CallMethods.unknown:
          return null;
        case CallMethods.objectVariationDetails:
          expect(featureId, 'jsonVariation', reason: "featureId is not match");
          expect(defaultValue is String && defaultValue == "{}", true,
              reason: "defaultValue is not match");
          return {
            'status': true,
            'response': {
              'featureId': 'jsonVariation',
              'featureVersion': 123,
              'userId': 'userId123',
              'variationId': 'variationId123',
              'variationName': 'variationName123',
              'variationValue': {
                'id': 'id123',
                'featureId': 'featureId123',
                'featureVersion': 123,
                'enable': true
              },
              'reason': 'DEFAULT',
            }
          };
        case CallMethods.intVariationDetails:
          expect(featureId, 'intVariation', reason: "featureId is not match");
          expect(defaultValue is int && defaultValue == 1, true,
              reason: "defaultValue is not match");
          return {
            'status': true,
            'response': {
              'id': 'id123',
              'featureId': 'intVariation',
              'featureVersion': 123,
              'userId': 'userId123',
              'variationId': 'variationId123',
              'variationName': 'variationName123',
              'variationValue': 1234,
              'reason': 'DEFAULT',
            }
          };
        case CallMethods.boolVariationDetails:
          expect(featureId, 'boolVariation', reason: "featureId is not match");
          expect(defaultValue is bool && defaultValue == false, true,
              reason: "defaultValue is not match");
          return {
            'status': true,
            'response': {
              'id': 'id123',
              'featureId': 'boolVariation',
              'featureVersion': 123,
              'userId': 'userId123',
              'variationId': 'variationId123',
              'variationName': 'variationName123',
              'variationValue': true,
              'reason': 'DEFAULT',
            }
          };
        case CallMethods.doubleVariationDetails:
          expect(featureId, 'doubleVariation',
              reason: "featureId is not match");
          expect(defaultValue is double && defaultValue == 1.0, true,
              reason: "defaultValue is not match");
          return {
            'status': true,
            'response': {
              'id': 'id123',
              'featureId': 'doubleVariation',
              'featureVersion': 123,
              'userId': 'userId123',
              'variationId': 'variationId123',
              'variationName': 'variationName123',
              'variationValue': 55.2,
              'reason': 'DEFAULT',
            }
          };
        case CallMethods.stringVariationDetails:
          expect(featureId, 'stringVariation',
              reason: "featureId is not match");
          expect(defaultValue is String && defaultValue == "default", true,
              reason: "defaultValue is not match");
          return {
            'status': true,
            'response': {
              'id': 'id123',
              'featureId': 'stringVariation',
              'featureVersion': 123,
              'userId': 'userId123',
              'variationId': 'variationId123',
              'variationName': 'variationName123',
              'variationValue': "datadata",
              'reason': 'DEFAULT',
            }
          };
      }
    });

    final config = BKTConfigBuilder()
        .apiKey("apikey")
        .apiEndpoint("api.bucketeer.io")
        .featureTag('Flutter')
        .debugging(true)
        .eventsMaxQueueSize(10000)
        .eventsFlushInterval(10000)
        .pollingInterval(10000)
        .backgroundPollingInterval(10000)
        .appVersion("1.0.0")
        .build();
    final user = BKTUserBuilder()
        .id("userI123")
        .customAttributes({'app_version': '1.0.0'}).build();

    await expectLater(
      BKTClient.initialize(
        config: config,
        user: user,
      ),
      completion(
        equals(const BKTResult.success()),
      ),
    );
  });

  tearDown(() async {
    /// Void method should not throw exception
    await expectLater(
      BKTClient.instance.destroy().onError((error, stackTrace) =>
          fail("BKTClient.instance.destroy should not throw an exception")),
      completion(
        equals(const BKTResult.success()),
      ),
    );
  });

  group('Bucketeer Success Cases Tests', () {
    test("addEvaluationUpdateListener", () async {
      await expectLater(
        BKTClient.instance
            .addEvaluationUpdateListener(MockEvaluationUpdateListener())
            .then((value) {
          return ProxyEvaluationUpdateListenToken.getToken();
        }),
        completion(
          equals('00673eaf-364f-49a7-84cb-b4d723a6ac5d'),
        ),
      );
    });

    test("flush", () async {
      await expectLater(
        BKTClient.instance.flush(),
        completion(
          equals(const BKTResult.success()),
        ),
      );
    });

    test("fetchEvaluations", () async {
      await expectLater(
        BKTClient.instance.fetchEvaluations(timeoutMillis: 10000),
        completion(
          equals(const BKTResult.success()),
        ),
      );
    });

    test("currentUser", () async {
      await expectLater(
        BKTClient.instance.currentUser(),
        completion(
          equals(
            BKTResult<BKTUser>.success(
                data: BKTUserBuilder().id('userId123').customAttributes(
              {
                'appVersion': '9.9.9',
                'platform': 'iOS',
              },
            ).build()),
          ),
        ),
      );
    });

    test("stringVariation", () async {
      await expectLater(
        BKTClient.instance
            .stringVariation('stringVariation', defaultValue: 'default'),
        completion(
          equals('datadata'),
        ),
      );

      await expectLater(
        BKTClient.instance
            .stringVariationDetails('stringVariation', defaultValue: 'default'),
        completion(
          const BKTEvaluationDetails<String>(
            featureId: 'stringVariation',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: 'datadata',
            reason: "DEFAULT",
          ),
        ),
      );
    });

    test("jsonVariation", () async {
      expect(
        // ignore: deprecated_member_use_from_same_package
        (await BKTClient.instance.jsonVariation('jsonVariation', defaultValue: {})),
        Map<String, dynamic>.from(
          {
            'id': 'id123',
            'featureId': 'featureId123',
            'featureVersion': 123,
            'enable': true,
          },
        ),
      );
    });

    test("objectVariation", () async {
      expect(
        (await BKTClient.instance.objectVariation(
          'jsonVariation',
          defaultValue: const BKTStructure({}),
        )),
        const BKTStructure({
          'id': BKTString('id123'),
          'featureId': BKTString('featureId123'),
          'featureVersion': BKTNumber(123),
          'enable': BKTBoolean(true),
        }),
      );

      expect(
        (await BKTClient.instance.objectVariationDetails(
          'jsonVariation',
          defaultValue: const BKTStructure({}),
        )),
        const BKTEvaluationDetails<BKTValue>(
          featureId: 'jsonVariation',
          featureVersion: 123,
          userId: 'userId123',
          variationId: 'variationId123',
          variationName: 'variationName123',
          variationValue: BKTStructure({
            'id': BKTString('id123'),
            'featureId': BKTString('featureId123'),
            'featureVersion': BKTNumber(123),
            'enable': BKTBoolean(true),
          }),
          reason: "DEFAULT",
        ),
      );

      expect(
        (await BKTClient.instance.objectVariationDetails(
          'jsonVariation',
          defaultValue: const BKTStructure({}),
        )),
        isNot(
          equals(
            const BKTEvaluationDetails<BKTValue>(
              featureId: 'jsonVariation',
              featureVersion: 123,
              userId: 'userId123',
              variationId: 'variationId123',
              variationName: 'variationName123',
              variationValue: BKTStructure({
                'id': BKTString('id123'),
                'featureId': BKTString('featureId123'),
              }),
              reason: "DEFAULT",
            ),
          ),
        ),
      );
    });

    test("intVariation", () async {
      await expectLater(
        BKTClient.instance.intVariation('intVariation', defaultValue: 1),
        completion(
          equals(1234),
        ),
      );

      await expectLater(
        BKTClient.instance.intVariationDetails('intVariation', defaultValue: 1),
        completion(
          const BKTEvaluationDetails<int>(
            featureId: 'intVariation',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: 1234,
            reason: "DEFAULT",
          ),
        ),
      );
    });

    test("doubleVariation", () async {
      await expectLater(
        BKTClient.instance
            .doubleVariation('doubleVariation', defaultValue: 1.0),
        completion(
          equals(55.2),
        ),
      );

      await expectLater(
        BKTClient.instance
            .doubleVariationDetails('doubleVariation', defaultValue: 1.0),
        completion(
          const BKTEvaluationDetails<double>(
            featureId: 'doubleVariation',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: 55.2,
            reason: "DEFAULT",
          ),
        ),
      );
    });

    test("boolVariation", () async {
      await expectLater(
        BKTClient.instance.boolVariation('boolVariation', defaultValue: false),
        completion(
          equals(true),
        ),
      );

      await expectLater(
        BKTClient.instance
            .boolVariationDetails('boolVariation', defaultValue: false),
        completion(
          const BKTEvaluationDetails<bool>(
            featureId: 'boolVariation',
            featureVersion: 123,
            userId: 'userId123',
            variationId: 'variationId123',
            variationName: 'variationName123',
            variationValue: true,
            reason: "DEFAULT",
          ),
        ),
      );
    });

    test("boolVariation", () async {
      await expectLater(
        // ignore: deprecated_member_use_from_same_package
        BKTClient.instance.evaluationDetails('featureId'),
        completion(
          equals(
            // ignore: deprecated_member_use_from_same_package
            const BKTEvaluation(
              id: 'id123',
              featureId: 'featureId123',
              featureVersion: 123,
              userId: 'userId123',
              variationId: 'variationId123',
              variationName: 'variationName123',
              variationValue: 'variationValue123',
              reason: "DEFAULT",
            ),
          ),
        ),
      );
    });

    test("updateUserAttributes", () async {
      /// Void method should not throw exception
      await expectLater(
        BKTClient.instance.updateUserAttributes(
          {'app_version': '1.0.0'},
        ).onError((error, stackTrace) => fail(
            "BKTClient.instance.updateUserAttributes should not throw an exception")),
        completion(
          equals(const BKTResult.success()),
        ),
      );
    });

    test("track", () async {
      /// Void method should not throw exception
      await expectLater(
        BKTClient.instance.track('goal-id').onError((error, stackTrace) =>
            fail("BKTClient.instance.track should not throw an exception")),
        completion(
          equals(const BKTResult.success()),
        ),
      );
    });
  });

  group('Bucketeer Should Return Default Value Cases Tests', () {
    test("stringVariation", () async {
      await expectLater(
        BKTClient.instance
            .stringVariation('stringVariationNotFound', defaultValue: ''),
        completion(
          equals(''),
        ),
      );

      await expectLater(
        BKTClient.instance.stringVariationDetails('stringVariationNotFound',
            defaultValue: 'default'),
        completion(
          const BKTEvaluationDetails<String>(
            featureId: 'stringVariationNotFound',
            featureVersion: 0,
            userId: 'userId123',
            variationId: '',
            variationName: '',
            variationValue: 'default',
            reason: "CLIENT",
          ),
        ),
      );
    });

    test("jsonVariation", () async {
      expect(
        // ignore: deprecated_member_use_from_same_package
        (await BKTClient.instance.jsonVariation('jsonVariationNotFound', defaultValue: {
          'id': 'id123',
        })),
        Map<String, dynamic>.from(
          {
            'id': 'id123',
          },
        ),
      );
    });

    test("objectVariation", () async {
      expect(
        (await BKTClient.instance.objectVariation(
          'jsonVariationNotFound',
          defaultValue: const BKTStructure({
            'id': BKTString('id123'),
          }),
        )),
        const BKTStructure({
          'id': BKTString('id123'),
        }),
      );

      expect(
        (await BKTClient.instance.objectVariationDetails(
          'jsonVariationNotFound',
          defaultValue: const BKTStructure({
            'id': BKTString('id123'),
          }),
        )),
        const BKTEvaluationDetails<BKTValue>(
          featureId: 'jsonVariationNotFound',
          featureVersion: 0,
          userId: 'userId123',
          variationId: '',
          variationName: '',
          variationValue: BKTStructure({
            'id': BKTString('id123'),
          }),
          reason: "CLIENT",
        ),
      );
    });

    test("intVariation", () async {
      await expectLater(
        BKTClient.instance
            .intVariation('intVariationNotFound', defaultValue: 1),
        completion(
          equals(1),
        ),
      );

      await expectLater(
        BKTClient.instance
            .intVariationDetails('intVariationNotFound', defaultValue: 1),
        completion(
          const BKTEvaluationDetails<int>(
            featureId: 'intVariationNotFound',
            featureVersion: 0,
            userId: 'userId123',
            variationId: '',
            variationName: '',
            variationValue: 1,
            reason: "CLIENT",
          ),
        ),
      );
    });

    test("doubleVariation", () async {
      await expectLater(
        BKTClient.instance
            .doubleVariation('doubleVariationNotFound', defaultValue: 0.1),
        completion(
          equals(0.1),
        ),
      );

      await expectLater(
        BKTClient.instance.doubleVariationDetails('doubleVariationNotFound',
            defaultValue: 1.2),
        completion(
          const BKTEvaluationDetails<double>(
            featureId: 'doubleVariationNotFound',
            featureVersion: 0,
            userId: 'userId123',
            variationId: '',
            variationName: '',
            variationValue: 1.2,
            reason: "CLIENT",
          ),
        ),
      );
    });

    test("boolVariation", () async {
      await expectLater(
        BKTClient.instance
            .boolVariation('boolVariationNotFound', defaultValue: true),
        completion(
          equals(true),
        ),
      );

      await expectLater(
        BKTClient.instance.doubleVariationDetails('doubleVariationNotFound',
            defaultValue: 1.2),
        completion(
          const BKTEvaluationDetails<double>(
            featureId: 'doubleVariationNotFound',
            featureVersion: 0,
            userId: 'userId123',
            variationId: '',
            variationName: '',
            variationValue: 1.2,
            reason: "CLIENT",
          ),
        ),
      );
    });
  });
}
