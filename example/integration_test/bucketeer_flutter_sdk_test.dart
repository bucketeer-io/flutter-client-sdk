import 'dart:async';

import 'package:bucketeer_example/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:mocktail/mocktail.dart';

class MockEvaluationUpdateListener extends Mock
    implements BKTEvaluationUpdateListener {}

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const String appVersion = "1.2.3";
  const String oldAppVersion = "0.0.1";
  const bool debugging = true;

  // E2E Flutter
  const String featureTag = "flutter";
  const String userId = 'bucketeer-flutter-user-id-1';

  const String featureIdBoolean = "feature-flutter-e2e-boolean";
  const bool featureIdBooleanValue = true;

  const String featureIdString = "feature-flutter-e2e-string";
  const String featureIdStringValue = "value-1";
  const String featureIdStringValueUpdate = "value-2";

  const String featureIdInt = "feature-flutter-e2e-int";
  const int featureIdIntValue = 10;

  const String featureIdDouble = "feature-flutter-e2e-double";
  const double featureIdDoubleValue = 2.1;

  const String featureIdJson = "feature-flutter-e2e-json";
  const Map<String, dynamic> featureIdJsonValue = {"key": "value-1"};

  const String goalId = "goal-flutter-e2e-1";
  const double goalValue = 1.0;

  group('Bucketeer: general test', () {
    setUpAll(() async {
      final config = BKTConfigBuilder()
          .apiKey(Constants.apiKey)
          .apiEndpoint(Constants.apiEndpoint)
          .featureTag(featureTag)
          .debugging(debugging)
          .eventsMaxQueueSize(Constants.exampleEventMaxQueueSize)
          .eventsFlushInterval(Constants.exampleEventsFlushInterval)
          .pollingInterval(Constants.examplePollingInterval)
          .backgroundPollingInterval(Constants.exampleBackgroundPollingInterval)
          .appVersion(appVersion)
          .build();
      final user = BKTUserBuilder().id(userId).customAttributes({}).build();

      await BKTClient.initialize(
        config: config,
        user: user,
      ).then(
        (instanceResult) {
          expect(instanceResult.isInitializeSuccess(), true,
              reason:
                  "initialize() should success ${instanceResult.toString()}");
        },
      );
    });

    setUp(() async {});

    tearDown(() async {});

    tearDownAll(() async {
      await BKTClient.instance.flush().onError((error, stackTrace) => fail(
          "BKTClient.instance.flush should succeed and should not throw an exception. Error: $error"));
      await BKTClient.instance.destroy().onError((error, stackTrace) => fail(
          "BKTClient.instance.destroy should succeed and should not throw an exception. Error: $error"));
      debugPrint("Bucketeer tests finished");
    });

    testWidgets('testStringVariation', (WidgetTester _) async {
      expectLater(
        BKTClient.instance
            .stringVariation(featureIdString, defaultValue: "test"),
        completion(
          equals(featureIdStringValue),
        ),
      );
    });

    testWidgets('testStringVariationDetail', (WidgetTester _) async {
      var result = await BKTClient.instance.evaluationDetails(featureIdString);
      var expected = const BKTEvaluation(
          id: "$featureIdString:4:$userId",
          featureId: featureIdString,
          featureVersion: 4,
          userId: userId,
          variationId: "2e696c59-ac2f-4b54-82a7-4aecfdd80224",
          variationName: "variation 1",
          variationValue: "value-1",
          reason: "DEFAULT");
      expect(result, expected);
    });

    testWidgets('testDoubleVariation', (WidgetTester _) async {
      expectLater(
        BKTClient.instance
            .doubleVariation(featureIdDouble, defaultValue: 100.0),
        completion(
          equals(featureIdDoubleValue),
        ),
      );
    });

    testWidgets('testDoubleVariationDetail', (WidgetTester _) async {
      var result = await BKTClient.instance.evaluationDetails(featureIdDouble);
      var expected = const BKTEvaluation(
          id: "$featureIdDouble:3:$userId",
          featureId: featureIdDouble,
          featureVersion: 3,
          userId: userId,
          variationId: "a141d1fa-85ef-4124-af5e-25374225474b",
          variationName: "variation 2.1",
          variationValue: "2.1",
          reason: "DEFAULT");
      expect(result, expected);
    });

    testWidgets('testBoolVariation', (WidgetTester _) async {
      expectLater(
        BKTClient.instance.boolVariation(featureIdBoolean, defaultValue: false),
        completion(
          equals(featureIdBooleanValue),
        ),
      );
    });
    testWidgets('testBoolVariationDetail', (WidgetTester _) async {
      var result = await BKTClient.instance.evaluationDetails(featureIdBoolean);
      var expected = const BKTEvaluation(
          id: "$featureIdBoolean:3:$userId",
          featureId: featureIdBoolean,
          featureVersion: 3,
          userId: userId,
          variationId: "cbd42331-094e-4306-aacd-d7bf3f07cf65",
          variationName: "variation true",
          variationValue: "true",
          reason: "DEFAULT");
      expect(result, expected);
    });

    testWidgets('testIntVariation', (WidgetTester _) async {
      expectLater(
        BKTClient.instance.intVariation(featureIdInt, defaultValue: 1000),
        completion(
          equals(featureIdIntValue),
        ),
      );
    });
    testWidgets('testIntVariationDetail', (WidgetTester _) async {
      var result = await BKTClient.instance.evaluationDetails(featureIdInt);
      var expected = const BKTEvaluation(
          id: "$featureIdInt:3:$userId",
          featureId: featureIdInt,
          featureVersion: 3,
          userId: userId,
          variationId: "36f14c02-300a-48f3-b4eb-b296afba3953",
          variationName: "variation 10",
          variationValue: "10",
          reason: "DEFAULT");
      expect(result, expected);
    });

    testWidgets('testJSONVariation', (WidgetTester _) async {
      var result = await BKTClient.instance
          .jsonVariation(featureIdJson, defaultValue: {});
      expect(result, featureIdJsonValue);
    });
    testWidgets('testJSONVariationDetail', (WidgetTester _) async {
      var result = await BKTClient.instance.evaluationDetails(featureIdJson);
      var expected = const BKTEvaluation(
          id: "$featureIdJson:3:$userId",
          featureId: featureIdJson,
          featureVersion: 3,
          userId: userId,
          variationId: "813070cf-7d6b-45a9-8713-cf9816d63997",
          variationName: "variation 1",
          variationValue: "{ \"key\": \"value-1\" }",
          reason: "DEFAULT");
      expect(result, expected);
    });

    testWidgets('testTrack', (WidgetTester _) async {
      await BKTClient.instance.track(goalId, value: goalValue).onError(
          (error, stackTrace) =>
              fail("BKTClient.instance.track should succeed. Error: $error"));

      var flushResult = await BKTClient.instance.flush();
      expect(flushResult, const BKTResult.success());
    });

    testWidgets('testUpdateUserAttributes', (WidgetTester _) async {
      var userRs = await BKTClient.instance.currentUser();
      expect(userRs.isSuccess, true);
      var user = userRs.asSuccess.data;
      expect(user, BKTUserBuilder().id(userId).customAttributes({}).build());
      await BKTClient.instance.updateUserAttributes(
        {'app_version': appVersion},
      ).onError((error, stackTrace) => fail(
          "BKTClient.instance.updateUserAttributes should succeed and should not throw an exception. Error: $error"));
      userRs = await BKTClient.instance.currentUser();
      expect(userRs.isSuccess, true);
      user = userRs.asSuccess.data;
      expect(
          user,
          BKTUserBuilder()
              .id(userId)
              .customAttributes({'app_version': appVersion}).build());
    });

    testWidgets('testFetchEvaluationsWithTimeout', (WidgetTester _) async {
      var fetchEvaluationsResult = await BKTClient.instance
          .fetchEvaluations(timeoutMillis: 30000)
          .timeout(const Duration(milliseconds: 31000), onTimeout: () {
        fail("fetchEvaluations should time out under 30000ms");
      });
      expect(fetchEvaluationsResult.isSuccess, true,
          reason: "fetchEvaluations() should succeed");
    });

    // This test also checks the `EvaluationUpdateListener` if it is called
    testWidgets('testEvaluationUpdateFlow', (WidgetTester _) async {
      await expectLater(
        BKTClient.instance
            .stringVariation(featureIdString, defaultValue: "test"),
        completion(
          equals(featureIdStringValue),
        ),
      );

      final listener = MockEvaluationUpdateListener();
      final listenToken =
          await BKTClient.instance.addEvaluationUpdateListener(listener);

      // Ensure that the `listener.onUpdate()` is called.
      // Use Completer to convert the listener callback to a future.
      var completer = Completer();
      when(() => listener.onUpdate()).thenAnswer((invocation) {
        completer.complete();
      });

      // Ensure that the attributes are update before calling `fetchEvaluations`
      await BKTClient.instance.updateUserAttributes(
        {'app_version': oldAppVersion},
      ).onError((error, stackTrace) => fail(
          "BKTClient.instance.updateUserAttributes should succeed and should not throw an exception. Error: $error"));

      // Do NOT use `await` here. Otherwise, the complete won't be called
      BKTClient.instance.fetchEvaluations(timeoutMillis: 30000);

      // Wait for `fetchEvaluations` to finish.
      await completer.future.timeout(const Duration(seconds: 60),
          onTimeout: () {
        fail("The OnUpdate callback should be called under 60 seconds");
      });

      // Remove the listener ASAP to avoid random exception logs in the background
      // when the completer is called because the client is still running
      BKTClient.instance.removeEvaluationUpdateListener(listenToken);

      var onUpdateCallCount = verify(() => listener.onUpdate()).callCount;
      // The listener should called at least once.
      // Because the fetch process during the initializing might finish
      // before adding the listener, we check if it was called at least once.
      expect(onUpdateCallCount >= 1, true,
          reason:
              "The OnUpdate callback should be called at least once. Called $onUpdateCallCount times");

      debugPrint(
          "testEvaluationUpdateFlow `OnUpdate` called $onUpdateCallCount times");

      await expectLater(
        BKTClient.instance
            .stringVariation(featureIdString, defaultValue: "test"),
        completion(
          equals(featureIdStringValueUpdate),
        ),
      );
    });

    testWidgets('testSwitchUser', (WidgetTester _) async {
      await BKTClient.instance.destroy().onError((error, stackTrace) => fail(
          "BKTClient.instance.destroy should success and should not throw an exception. Error: ${error.toString()}"));

      final config = BKTConfigBuilder()
          .apiKey(Constants.apiKey)
          .apiEndpoint(Constants.apiEndpoint)
          .featureTag(featureTag)
          .debugging(debugging)
          .eventsMaxQueueSize(Constants.exampleEventMaxQueueSize)
          .eventsFlushInterval(Constants.exampleEventsFlushInterval)
          .pollingInterval(Constants.examplePollingInterval)
          .backgroundPollingInterval(Constants.exampleBackgroundPollingInterval)
          .appVersion(appVersion)
          .build();
      final user = BKTUserBuilder().id("test_id").customAttributes({}).build();

      var instanceResult = await BKTClient.initialize(
        config: config,
        user: user,
      );
      expect(instanceResult.isInitializeSuccess(), true,
          reason: "initialize() should succeed");

      await BKTClient.instance.updateUserAttributes(
        {'app_version': appVersion},
      ).onError((error, stackTrace) => fail(
          "BKTClient.instance.updateUserAttributes should succeed and should not throw an exception. Error: ${error.toString()}"));

      var currentUserRs = await BKTClient.instance.currentUser();
      expect(currentUserRs.isSuccess, true,
          reason: "BKTClient.instance.currentUser() should return user data");
      final currentUser = currentUserRs.asSuccess.data;

      expect(currentUser.id, "test_id", reason: "user_id should be `test_id`");
      expect(currentUser.attributes, {'app_version': appVersion},
          reason: "user_data should match");

      var fetchEvaluationsResult =
          await BKTClient.instance.fetchEvaluations(timeoutMillis: 30000);
      expect(fetchEvaluationsResult.isSuccess, true,
          reason: "fetchEvaluations() should succeed");

      await BKTClient.instance.destroy().then((value) {
        expect(value.isSuccess, true, reason: "destroy() should succeed");
      }).onError((error, stackTrace) => fail(
          "destroy() should success and should not throw an exception ${error.toString()}"));
    });
  });

  group('Bucketeer: test optional configurations', () {
    setUp(() {});

    test('BKTClient should allow feature_tag to be optional', () async {
      final config = BKTConfigBuilder()
          .apiKey(Constants.apiKey)
          .apiEndpoint(Constants.apiEndpoint)
          .debugging(debugging)
          .eventsMaxQueueSize(Constants.exampleEventMaxQueueSize)
          .eventsFlushInterval(Constants.exampleEventsFlushInterval)
          .pollingInterval(Constants.examplePollingInterval)
          .backgroundPollingInterval(Constants.exampleBackgroundPollingInterval)
          .appVersion(appVersion)
          .build();
      assert(config.featureTag == "");
      final user = BKTUserBuilder().id(userId).customAttributes({}).build();

      await BKTClient.initialize(
        config: config,
        user: user,
      ).then((instanceResult) {
        expect(instanceResult.isInitializeSuccess(), true,
            reason: "initialize() should success");
      }, onError: (obj, st) {
        fail('initialize() should not throw an exception');
      });

      /// init without feature tag should retrieves all features
      final android = await BKTClient.instance
          .evaluationDetails("feature-android-e2e-string");
      expect(android != null, true,
          reason: "evaluationDetails should not be null");

      final golang =
          await BKTClient.instance.evaluationDetails("feature-go-server-e2e-1");
      expect(golang != null, true,
          reason: "evaluationDetails should not be null");

      final javascript =
          await BKTClient.instance.evaluationDetails("feature-js-e2e-string");
      expect(javascript != null, true,
          reason: "evaluationDetails should not be null");
    });

    tearDown(() async {
      await BKTClient.instance.destroy().then((value) {
        expect(value.isSuccess, true, reason: "destroy() should success");
      }, onError: (obj, st) {
        fail("destroy() should success and should not throw an exception");
      });
    });
  });

  group('Bucketeer: error handling', () {
    testWidgets('access BKTClient before initializing', (WidgetTester _) async {
      var completer = Completer<BKTResult<void>>();
      BKTResult<void> fetchEvaluationsRs =
          await BKTClient.instance.fetchEvaluations().then((value) {
        /// Use completer to make sure this callback will get called
        /// even if BKTClient has not initialize
        completer.complete(value);
        return value;
      }, onError: (obj, st) {
        fail("fetchEvaluations() should not throw an exception");
      });
      expect(fetchEvaluationsRs.isFailure, true,
          reason:
              "fetchEvaluations() should fail ${fetchEvaluationsRs.toString()}");
      expect(fetchEvaluationsRs.asFailure.exception,
          isA<BKTIllegalStateException>(),
          reason:
              "exception should be BKTIllegalStateException but got ${fetchEvaluationsRs.toString()}");

      BKTResult<void> flushRs = await BKTClient.instance.flush().then((value) {
        return value;
      }, onError: (obj, st) {
        fail("flush() should not throw an exception");
      });
      expect(flushRs.isFailure, true, reason: "flush() should fail");
      expect(fetchEvaluationsRs.asFailure.exception,
          isA<BKTIllegalStateException>(),
          reason:
              "exception should be BKTIllegalStateException but got ${fetchEvaluationsRs.toString()}");

      expect(completer.isCompleted, true,
          reason: "completer should be completed");
    });

    testWidgets('initialize BKTClient with invalid API_KEY',
        (WidgetTester _) async {
      final config = BKTConfigBuilder()
          .apiKey("RANDOM_KEY")
          .apiEndpoint(Constants.apiEndpoint)
          .debugging(debugging)
          .eventsMaxQueueSize(Constants.exampleEventMaxQueueSize)
          .eventsFlushInterval(Constants.exampleEventsFlushInterval)
          .pollingInterval(Constants.examplePollingInterval)
          .backgroundPollingInterval(Constants.exampleBackgroundPollingInterval)
          .appVersion(appVersion)
          .build();
      assert(config.featureTag == "");
      final user = BKTUserBuilder().id(userId).customAttributes({}).build();

      await BKTClient.initialize(
        config: config,
        user: user,
      ).then((instanceResult) {
        expect(instanceResult.isFailure, true,
            reason: "initialize() should fail ${instanceResult.toString()}");
        expect(instanceResult.asFailure.exception, isA<BKTForbiddenException>(),
            reason:
                "exception should be BKTForbiddenException but got ${instanceResult.toString()}. The exception could be a BKTTimeoutException, but we don't want it here");
      }, onError: (obj, st) {
        fail("initialize() should not throw an exception");
      });

      await BKTClient.instance.fetchEvaluations().then((fetchEvaluationsRs) {
        expect(fetchEvaluationsRs.asFailure.exception,
            isA<BKTForbiddenException>(),
            reason:
                "exception should be BKTForbiddenException but got ${fetchEvaluationsRs.toString()}");
      }, onError: (obj, st) {
        fail(
            "fetchEvaluations() should not throw an exception ${obj.toString()}");
      });

      await BKTClient.instance.flush().then((flushRs) {
        expect(flushRs.asFailure.exception, isA<BKTForbiddenException>(),
            reason:
                "exception should be BKTForbiddenException but got ${flushRs.toString()}");
        return flushRs;
      }, onError: (obj, st) {
        fail(
            "fetchEvaluations() should not throw an exception but got ${obj.toString()}");
      });

      await BKTClient.instance.destroy().then(
          (value) =>
              expect(value.isSuccess, true, reason: "destroy() should succeed"),
          onError: (obj, st) {
        fail("destroy() should not throw an exception");
      });

      await BKTClient.instance.fetchEvaluations().then((fetchEvaluationsRs) {
        expect(fetchEvaluationsRs.isFailure, true,
            reason: "fetchEvaluations() should fail");
        expect(fetchEvaluationsRs.asFailure.exception,
            isA<BKTIllegalStateException>(),
            reason:
                "exception should be BKTIllegalStateException but got ${fetchEvaluationsRs.toString()}");
      }, onError: (obj, st) {
        fail(
            "fetchEvaluations() should not throw an exception ${obj.toString()}");
      });
    });
  });
}

extension InitializeSuccess on BKTResult<void> {
  bool isInitializeSuccess() {
    return isSuccess || asFailure.exception is BKTTimeoutException;
  }
}
