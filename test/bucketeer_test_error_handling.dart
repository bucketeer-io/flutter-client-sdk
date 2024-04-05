import 'package:flutter/services.dart';
import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:bucketeer_flutter_client_sdk/src/call_methods.dart';
import 'package:bucketeer_flutter_client_sdk/src/constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(Constants.methodChannelName);

  tearDown(() {});

  group('Initialize fail', () {
    int mockErrorCode = 0;
    setUp(() async {
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (methodCall) async {
        return {
          'status': false,
          'errorCode': mockErrorCode,
          'errorMessage': 'fail'
        };
      });
    });

    test('Initialize fail with timeout error', () async {
      mockErrorCode = 11;

      /// time out error code
      final config = BKTConfigBuilder()
          .apiKey("apikeyapikeyapikeyapikeyapikeyapikeyapikey")
          .apiEndpoint("demo.bucketeer.jp")
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
      final rs = await BKTClient.initialize(
        config: config,
        user: user,
      );

      final expected = BKTResult.failure('fail',
          exception: BKTTimeoutException(message: 'fail'));
      expect(rs.isFailure, expected.isFailure);
      expect(rs.asFailure.exception == expected.asFailure.exception, true);
    });

    test('Initialize fail with other error - unauthorized', () async {
      mockErrorCode = 3;

      /// Unauthorized code ~ invalid API key
      final config = BKTConfigBuilder()
          .apiKey("apikeyapikeyapikeyapikeyapikeyapikeyapikey")
          .apiEndpoint("demo.bucketeer.jp")
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
      final rs = await BKTClient.initialize(
        config: config,
        user: user,
      );

      final expected = BKTResult.failure('fail',
          exception: BKTUnauthorizedException(message: 'fail'));
      expect(rs.isFailure, expected.isFailure);
      expect(rs.asFailure.exception == expected.asFailure.exception, true);
    });
  });

  group('Initialize success but fail when call function', () {
    int mockErrorCode = 4;
    setUp(() async {
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (methodCall) async {
        var callMethod = CallMethods.values.firstWhere(
            (element) => element.name == methodCall.method,
            orElse: () => CallMethods.unknown);
        switch (callMethod) {
          case CallMethods.initialize:
            return {
              'status': true,
              'response': {
                'id': 'userId',
                'data': {'appVersion': '9.9.9', 'platform': 'iOS'}
              }
            };
          default:
            return {
              'status': false,
              'errorCode': mockErrorCode,
              'errorMessage': 'fail'
            };
        }
      });
    });

    test('Bucketeer Error Handling Tests', () async {
      final config = BKTConfigBuilder()
          .apiKey("apikeyapikeyapikeyapikeyapikeyapikeyapikey")
          .apiEndpoint("demo.bucketeer.jp")
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

      /// Should return the null when catching an error
      var evaluationDetailsRs =
          await BKTClient.instance.evaluationDetails("not_found_featureId");
      expect(evaluationDetailsRs == null, equals(true),
          reason: "BKTClient.instance.evaluationDetails should return null");

      final fetchEvaluationsFailRs =
          await BKTClient.instance.fetchEvaluations(timeoutMillis: 10000);
      expect(fetchEvaluationsFailRs.isFailure, equals(true));
      expect(fetchEvaluationsFailRs.asFailure.exception,
          isA<BKTForbiddenException>());

      final flushFailRs = await BKTClient.instance.flush();
      expect(flushFailRs.isFailure, equals(true));
      expect(flushFailRs.asFailure.exception, isA<BKTForbiddenException>());

      final currentUserRs = await BKTClient.instance.currentUser();
      expect(currentUserRs.isFailure, equals(true),
          reason: "BKTClient.instance.currentUser().isFailure should be true");
      expect(currentUserRs.asFailure.exception, isA<BKTForbiddenException>());

      final updateUserAttributesRs = await BKTClient.instance
          .updateUserAttributes(
        {'app_version': '1.0.0'},
      ).onError((error, stackTrace) => fail(
              "BKTClient.instance.updateUserAttributes should not throw an exception"));
      expect(updateUserAttributesRs.asFailure.exception,
          isA<BKTForbiddenException>());

      final trackRs = await BKTClient.instance.track('goal-id').onError(
          (error, stackTrace) =>
              fail("BKTClient.instance.track should not throw an exception"));
      expect(trackRs.asFailure.exception, isA<BKTForbiddenException>());

      var evaluationDetails =
          await BKTClient.instance.evaluationDetails("not_found_featureId");
      expect(evaluationDetails == null, equals(true),
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
      expect(flushRs.asFailure.exception, isA<BKTForbiddenException>());

      final fetchEvaluationsRs =
          await BKTClient.instance.fetchEvaluations(timeoutMillis: 10000);
      expect(fetchEvaluationsRs.isFailure, true,
          reason:
              "BKTClient.instance.fetchEvaluations should return BKTResult.failure");
      expect(
          fetchEvaluationsRs.asFailure.exception, isA<BKTForbiddenException>());

      /// Void method should not throw exception
      final destroyRs = await BKTClient.instance.destroy().onError((error,
              stackTrace) =>
          fail("BKTClient.instance.destroy() should not throw an exception"));
      expect(destroyRs.asFailure.exception, isA<BKTForbiddenException>());
    });
  });

  group(
      'Initialize success but fail when call function because unknown exception',
      () {
    setUp(() async {
      TestWidgetsFlutterBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (methodCall) async {
        var callMethod = CallMethods.values.firstWhere(
            (element) => element.name == methodCall.method,
            orElse: () => CallMethods.unknown);
        switch (callMethod) {
          case CallMethods.initialize:
            return {
              'status': true,
              'response': {
                'id': 'userId',
                'data': {'appVersion': '9.9.9', 'platform': 'iOS'}
              }
            };
          default:
            throw Exception("unknown");
        }
      });
    });

    test('Bucketeer Error Handling Tests', () async {
      final config = BKTConfigBuilder()
          .apiKey("apikeyapikeyapikeyapikeyapikeyapikeyapikey")
          .apiEndpoint("demo.bucketeer.jp")
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

      /// Should return the null when catching an error
      var evaluationDetailsRs =
          await BKTClient.instance.evaluationDetails("not_found_featureId");
      expect(evaluationDetailsRs == null, equals(true),
          reason: "BKTClient.instance.evaluationDetails should return null");

      final fetchEvaluationsFailRs =
          await BKTClient.instance.fetchEvaluations(timeoutMillis: 10000);
      expect(fetchEvaluationsFailRs.isFailure, equals(true));
      expect(fetchEvaluationsFailRs.asFailure.exception,
          isA<BKTUnknownException>());

      final flushFailRs = await BKTClient.instance.flush();
      expect(flushFailRs.isFailure, equals(true));
      expect(flushFailRs.asFailure.exception, isA<BKTUnknownException>());

      final currentUserRs = await BKTClient.instance.currentUser();
      expect(currentUserRs.isFailure, equals(true),
          reason: "BKTClient.instance.currentUser().isFailure should be true");
      expect(currentUserRs.asFailure.exception, isA<BKTUnknownException>());

      final updateUserAttributesRs = await BKTClient.instance
          .updateUserAttributes(
        {'app_version': '1.0.0'},
      ).onError((error, stackTrace) => fail(
              "BKTClient.instance.updateUserAttributes should not throw an exception"));
      expect(updateUserAttributesRs.asFailure.exception,
          isA<BKTUnknownException>());

      final trackRs = await BKTClient.instance.track('goal-id').onError(
          (error, stackTrace) =>
              fail("BKTClient.instance.track should not throw an exception"));
      expect(trackRs.asFailure.exception, isA<BKTUnknownException>());

      var evaluationDetails =
          await BKTClient.instance.evaluationDetails("not_found_featureId");
      expect(evaluationDetails == null, equals(true),
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
      expect(flushRs.asFailure.exception, isA<BKTUnknownException>());

      final fetchEvaluationsRs =
          await BKTClient.instance.fetchEvaluations(timeoutMillis: 10000);
      expect(fetchEvaluationsRs.isFailure, true,
          reason:
              "BKTClient.instance.fetchEvaluations should return BKTResult.failure");
      expect(
          fetchEvaluationsRs.asFailure.exception, isA<BKTUnknownException>());

      /// Void method should not throw exception
      final destroyRs = await BKTClient.instance.destroy().onError((error,
              stackTrace) =>
          fail("BKTClient.instance.destroy() should not throw an exception"));
      expect(destroyRs.asFailure.exception, isA<BKTUnknownException>());
    });
  });
}
