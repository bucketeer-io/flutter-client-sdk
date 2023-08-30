import 'package:flutter/services.dart';
import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:bucketeer_flutter_client_sdk/src/call_methods.dart';
import 'package:bucketeer_flutter_client_sdk/src/constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(Constants.methodChannelName);
  var enableMockRuntimeError = false;
  var enableMockGetEvaluationDetailsNotFound = false;

  setUp(() async {
    TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (methodCall) async {
      if (enableMockRuntimeError) {
        throw Exception("test runtime error");
      }
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
          if (enableMockGetEvaluationDetailsNotFound) {
            return {'status': true, 'errorMessage': 'Feature flag not found.'};
          }
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
        case CallMethods.addEvaluationUpdateListener:
        case CallMethods.removeEvaluationUpdateListener:
        case CallMethods.clearEvaluationUpdateListeners:
        case CallMethods.unknown:
          return null;
      }
    });
  });

  tearDown(() {});

  test('Bucketeer Success Cases Tests', () async {
    final config = BKTConfigBuilder()
        .apiKey("apikeyapikeyapikeyapikeyapikeyapikeyapikey")
        .apiEndpoint("demo.bucketeer.io")
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
          BKTUserBuilder().id('userId').customAttributes(
            {
              'appVersion': '9.9.9',
              'platform': 'iOS',
            },
          ).build(),
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
    BKTClient.instance.updateUserAttributes(
      {'app_version': '1.0.0'},
    ).onError((error, stackTrace) => fail(
        "BKTClient.instance.updateUserAttributes should not throw an exception"));

    /// Void method should not throw exception
    BKTClient.instance.track('goal-id').onError((error, stackTrace) =>
        fail("BKTClient.instance.track should not throw an exception"));

    /// Void method should not throw exception
    await BKTClient.instance.destroy().onError((error, stackTrace) =>
        fail("BKTClient.instance.destroy should not throw an exception"));
  });

  test('Bucketeer Error Handling Tests', () async {
    final config = BKTConfigBuilder()
        .apiKey("apikeyapikeyapikeyapikeyapikeyapikeyapikey")
        .apiEndpoint("demo.bucketeer.io")
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

    enableMockGetEvaluationDetailsNotFound = true;

    /// Should return the null when catching an error
    var evaluationDetailsRs =
        await BKTClient.instance.evaluationDetails("not_found_featureId");
    expect(evaluationDetailsRs == null, equals(true),
        reason: "BKTClient.instance.evaluationDetails should return null");

    /// Test runtime error, all methods call under that line should fail
    enableMockRuntimeError = true;
    final fetchEvaluationsFailRs =
        await BKTClient.instance.fetchEvaluations(timeoutMillis: 10000);
    expect(fetchEvaluationsFailRs.isFailure, equals(true));

    final flushFailRs = await BKTClient.instance.flush();
    expect(flushFailRs.isFailure, equals(true));

    /// Should get `null`
    expectLater(
      BKTClient.instance.currentUser(),
      completion(
        equals(
          null,
        ),
      ),
      reason: "BKTClient.instance.currentUser should return null",
    );

    /// Void method should not throw exception
    BKTClient.instance.updateUserAttributes(
      {'app_version': '1.0.0'},
    ).onError((error, stackTrace) => fail(
        "BKTClient.instance.updateUserAttributes should not throw an exception"));

    /// Void method should not throw exception
    await BKTClient.instance.track('goal-id').onError((error, stackTrace) =>
        fail("BKTClient.instance.track should not throw an exception"));

    /// Void method should not throw exception
    var evaluationDetailsFailRs =
        await BKTClient.instance.evaluationDetails("not_found_featureId");
    expect(evaluationDetailsFailRs == null, equals(true),
        reason: "BKTClient.instance.evaluationDetails should return null");

    /// Should return the default value 200.0 when catching an error
    expectLater(
      BKTClient.instance.stringVariation('feature-id', defaultValue: 'bkt'),
      completion(
        equals('bkt'),
      ),
    );

    expect(
      (await BKTClient.instance.jsonVariation(
        'feature-id',
        defaultValue: {'value': 'default'},
      )),
      {'value': 'default'},
    );

    expectLater(
      BKTClient.instance.intVariation('feature-id', defaultValue: 90),
      completion(
        equals(90),
      ),
    );

    expectLater(
      BKTClient.instance.doubleVariation('feature-id', defaultValue: 110.0),
      completion(
        equals(110.0),
      ),
    );

    expectLater(
      BKTClient.instance.boolVariation('feature-id', defaultValue: false),
      completion(
        equals(false),
      ),
    );

    final flushRs = await BKTClient.instance.flush();
    expect(flushRs.isFailure, true,
        reason: "BKTClient.instance.flush should return BKTResult.failure");

    final fetchEvaluationsRs =
        await BKTClient.instance.fetchEvaluations(timeoutMillis: 10000);
    expect(fetchEvaluationsRs.isFailure, true,
        reason:
            "BKTClient.instance.fetchEvaluations should return BKTResult.failure");

    /// Void method should not throw exception
    await BKTClient.instance.destroy().onError((error, stackTrace) =>
        fail("BKTClient.instance.destroy() should not throw an exception"));

    /// Try re-initialize , but should fail
    final shouldFailInitializeRs = await BKTClient.initialize(
      config: config,
      user: user,
    );
    expect(shouldFailInitializeRs.isFailure, true,
        reason:
            "BKTClient.instance.initialize should return BKTResult.failure");
  });
}
