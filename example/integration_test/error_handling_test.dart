// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:bucketeer_example/constant.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'constant.dart';
import 'helper.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
    expect(
        fetchEvaluationsRs.asFailure.exception, isA<BKTIllegalStateException>(),
        reason:
            "exception should be BKTIllegalStateException but got ${fetchEvaluationsRs.toString()}");

    BKTResult<void> flushRs = await BKTClient.instance.flush().then((value) {
      return value;
    }, onError: (obj, st) {
      fail("flush() should not throw an exception");
    });
    expect(flushRs.isFailure, true, reason: "flush() should fail");
    expect(
        fetchEvaluationsRs.asFailure.exception, isA<BKTIllegalStateException>(),
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

    await E2EBKTClient.initializeWithRetryMechanism(
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
      expect(
          fetchEvaluationsRs.asFailure.exception, isA<BKTForbiddenException>(),
          reason:
              "exception should be BKTForbiddenException but got ${fetchEvaluationsRs.toString()}");
    }, onError: (obj, st) {
      fail(
          "fetchEvaluations() should not throw an exception ${obj.toString()}");
    });

    await BKTClient.instance.flush().then((flushRs) {
      expect(flushRs.isSuccess, true,
          reason:
              "flush() should succeed - because no data to flush after we skipped generate events for 401 & 403 errors");
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
}
