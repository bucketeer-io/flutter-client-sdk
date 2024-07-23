import 'package:bucketeer_flutter_client_sdk/src/evaluation.dart';
import 'package:bucketeer_flutter_client_sdk/src/proxy_evaluation_update_listener.dart';
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
              'id': 'userId',
              'data': {'appVersion': '9.9.9', 'platform': 'iOS'}
            }
          };
        case CallMethods.stringVariation:
          return {
            'status': false,
            'errorCode': -1,
            'errorMessage': 'should not be called, should call stringVariationDetails instead'
          };
        case CallMethods.intVariation:
          return {
            'status': false,
            'errorCode': -1,
            'errorMessage': 'should not be called, should call intVariationDetails instead'
          };
        case CallMethods.doubleVariation:
          return {
            'status': false,
            'errorCode': -1,
            'errorMessage': 'should not be called, should call doubleVariationDetails instead'
          };
        case CallMethods.boolVariation:
          return {
            'status': false,
            'errorCode': -1,
            'errorMessage': 'should not be called, should call boolVariationDetails instead'
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
          return {
            'status': false,
            'errorCode': -1,
            'errorMessage': 'should not be called, should call jsonVariationDetails instead'
          };
        case CallMethods.addProxyEvaluationUpdateListener:
          return {
            'status': true,
            'response': '00673eaf-364f-49a7-84cb-b4d723a6ac5d'
          };
        case CallMethods.unknown:
          return null;
        case CallMethods.jsonVariationDetails:
          expect(featureId, 'jsonVariation', reason: "featureId is not match");
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
          expect(featureId, 'doubleVariation', reason: "featureId is not match");
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
          expect(featureId, 'stringVariation', reason: "featureId is not match");
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
  });

  tearDown(() {});

  test('Bucketeer Success Cases Tests', () async {
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
        .id("2023")
        .customAttributes({'app_version': '1.0.0'}).build();

    expectLater(
      BKTClient.initialize(
        config: config,
        user: user,
      ),
      completion(
        equals(const BKTResult.success()),
      ),
    );

    expectLater(
      BKTClient.instance
          .addEvaluationUpdateListener(MockEvaluationUpdateListener())
          .then((value) {
        return ProxyEvaluationUpdateListenToken.getToken();
      }),
      completion(
        equals('00673eaf-364f-49a7-84cb-b4d723a6ac5d'),
      ),
    );

    expectLater(
      BKTClient.instance.flush(),
      completion(
        equals(const BKTResult.success()),
      ),
    );

    expectLater(
      BKTClient.instance.fetchEvaluations(timeoutMillis: 10000),
      completion(
        equals(const BKTResult.success()),
      ),
    );

    expectLater(
      BKTClient.instance.currentUser(),
      completion(
        equals(
          BKTResult<BKTUser>.success(
              data: BKTUserBuilder().id('userId').customAttributes(
            {
              'appVersion': '9.9.9',
              'platform': 'iOS',
            },
          ).build()),
        ),
      ),
    );

    expectLater(
      BKTClient.instance.stringVariation('stringVariation', defaultValue: ''),
      completion(
        equals('datadata'),
      ),
    );

    expectLater(
      BKTClient.instance.stringVariationDetails('stringVariation', defaultValue: ''),
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

    expect(
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

    expect(
      (await BKTClient.instance.jsonVariationDetails('jsonVariation', defaultValue: {})),
      const BKTEvaluationDetails<Map<String, dynamic>>(
        featureId: 'jsonVariation',
        featureVersion: 123,
        userId: 'userId123',
        variationId: 'variationId123',
        variationName: 'variationName123',
        variationValue: {
          'id': 'id123',
          'featureId': 'featureId123',
          'featureVersion': 123,
          'enable': true,
        },
        reason: "DEFAULT",
      ),
    );

    // expectLater(
    //   BKTClient.instance.jsonVariationDetails('jsonVariation', defaultValue: {}),
    //   completion(
    //     const BKTEvaluationDetails<Map<String, dynamic>>(
    //       featureId: 'jsonVariation',
    //       featureVersion: 123,
    //       userId: 'userId123',
    //       variationId: 'variationId123',
    //       variationName: 'variationName123',
    //       variationValue: {
    //         'id': 'id123',
    //         'featureId': 'featureId123',
    //         'featureVersion': 123,
    //         'enable': true,
    //       },
    //       reason: "DEFAULT",
    //     ),
    //   ),
    // );

    expectLater(
      BKTClient.instance.intVariation('intVariation', defaultValue: 0),
      completion(
        equals(1234),
      ),
    );

    expectLater(
      BKTClient.instance.doubleVariation('doubleVariation', defaultValue: 0.0),
      completion(
        equals(55.2),
      ),
    );

    expectLater(
      BKTClient.instance.boolVariation('boolVariation', defaultValue: false),
      completion(
        equals(true),
      ),
    );

    expectLater(
      // ignore: deprecated_member_use_from_same_package
      BKTClient.instance.evaluationDetails('featureId'),
      completion(
        equals(
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

    /// Void method should not throw exception
    expectLater(
      BKTClient.instance.updateUserAttributes(
        {'app_version': '1.0.0'},
      ).onError((error, stackTrace) => fail(
          "BKTClient.instance.updateUserAttributes should not throw an exception")),
      completion(
        equals(const BKTResult.success()),
      ),
    );

    /// Void method should not throw exception
    expectLater(
      BKTClient.instance.track('goal-id').onError((error, stackTrace) =>
          fail("BKTClient.instance.track should not throw an exception")),
      completion(
        equals(const BKTResult.success()),
      ),
    );

    /// Void method should not throw exception
    expectLater(
      BKTClient.instance.destroy().onError((error, stackTrace) =>
          fail("BKTClient.instance.destroy should not throw an exception")),
      completion(
        equals(const BKTResult.success()),
      ),
    );
  });
}
