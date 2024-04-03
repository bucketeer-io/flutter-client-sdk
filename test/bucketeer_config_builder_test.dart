import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BKTConfigBuilder Tests: error missing arguments', () async {
    final builderMissingAPIKey = BKTConfigBuilder();
    expect(
      () => builderMissingAPIKey.build(),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'apiKey is required',
          equals('apiKey is required'),
        ),
      ),
    );

    final builderMissingAPIEndpoint = BKTConfigBuilder().apiKey("api_key");
    expect(
      () => builderMissingAPIEndpoint.build(),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'apiEndpoint is required',
          equals('apiEndpoint is required'),
        ),
      ),
    );

    final builderMissingAppVersion = BKTConfigBuilder()
        .apiKey("api_key")
        .apiEndpoint("demo.bucketeer.io")
        .featureTag('Flutter')
        .debugging(true)
        .eventsMaxQueueSize(100)
        .eventsFlushInterval(120000)
        .pollingInterval(300000)
        .backgroundPollingInterval(1800000);
    expect(
      () => builderMissingAppVersion.build(),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'appVersion is required',
          equals('appVersion is required'),
        ),
      ),
    );
  });

  test('BKTConfigBuilder Tests: success with empty tag', () async {
    final config = BKTConfigBuilder()
        .apiKey("api_key")
        .apiEndpoint("demo.bucketeer.io")
        .debugging(true)
        .eventsMaxQueueSize(100)
        .eventsFlushInterval(120000)
        .pollingInterval(300000)
        .backgroundPollingInterval(1800000)
        .appVersion("1.0.0")
        .build();
    expect(config.apiKey, "api_key");
    expect(config.apiEndpoint, "demo.bucketeer.io");
    expect(config.featureTag, '');
    expect(config.debugging, true);
    expect(config.eventsMaxQueueSize, 100);
    expect(config.eventsFlushInterval, 120000);
    expect(config.pollingInterval, 300000);
    expect(config.backgroundPollingInterval, 1800000);
    expect(config.appVersion, "1.0.0");
  });

  test('BKTConfigBuilder Tests: success', () async {
    final config = BKTConfigBuilder()
        .apiKey("api_key")
        .apiEndpoint("demo.bucketeer.io")
        .featureTag('Flutter')
        .debugging(true)
        .eventsMaxQueueSize(100)
        .eventsFlushInterval(120000)
        .pollingInterval(300000)
        .backgroundPollingInterval(1800000)
        .appVersion("1.0.0")
        .build();
    expect(config.apiKey, "api_key");
    expect(config.apiEndpoint, "demo.bucketeer.io");
    expect(config.featureTag, 'Flutter');
    expect(config.debugging, true);
    expect(config.eventsMaxQueueSize, 100);
    expect(config.eventsFlushInterval, 120000);
    expect(config.pollingInterval, 300000);
    expect(config.backgroundPollingInterval, 1800000);
    expect(config.appVersion, "1.0.0");
  });
}
