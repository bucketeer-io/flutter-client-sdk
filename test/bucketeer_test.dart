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
          return {'status': true, 'response': 'datadata'};
        case CallMethods.intVariation:
          return {'status': true, 'response': 1234};
        case CallMethods.doubleVariation:
          return {'status': true, 'response': 55.2};
        case CallMethods.boolVariation:
          return {'status': true, 'response': true};
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
            'status': true,
            'response': {
              'id': 'id123',
              'featureId': 'featureId123',
              'featureVersion': 123,
              'enable': true,
            }
          };
        case CallMethods.addProxyEvaluationUpdateListener:
          return {
            'status': true,
            'response': '00673eaf-364f-49a7-84cb-b4d723a6ac5d'
          };
        case CallMethods.unknown:
          return null;
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
      BKTClient.instance.stringVariation('feature-id', defaultValue: ''),
      completion(
        equals('datadata'),
      ),
    );

    expect(
      (await BKTClient.instance.jsonVariation('feature-id', defaultValue: {})),
      Map<String, dynamic>.from(
        {
          'id': 'id123',
          'featureId': 'featureId123',
          'featureVersion': 123,
          'enable': true,
        },
      ),
    );

    expectLater(
      BKTClient.instance.intVariation('feature-id', defaultValue: 0),
      completion(
        equals(1234),
      ),
    );

    expectLater(
      BKTClient.instance.doubleVariation('feature-id', defaultValue: 0.0),
      completion(
        equals(55.2),
      ),
    );

    expectLater(
      BKTClient.instance.boolVariation('feature-id', defaultValue: false),
      completion(
        equals(true),
      ),
    );

    expectLater(
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
