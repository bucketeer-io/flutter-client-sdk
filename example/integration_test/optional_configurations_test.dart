// ignore_for_file: deprecated_member_use
import 'package:bucketeer_example/constant.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:mocktail/mocktail.dart';

import 'helper.dart';
import 'constant.dart';

class MockEvaluationUpdateListener extends Mock
    implements BKTEvaluationUpdateListener {}

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Bucketeer: test optional configurations', () {
    setUp(() {});

    testWidgets('BKTClient should allow feature_tag to be optional', (WidgetTester _) async {
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

      await E2EBKTClient.initializeWithRetryMechanism(
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
}