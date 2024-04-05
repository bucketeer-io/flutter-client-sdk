import 'package:flutter/cupertino.dart';

@immutable
class BKTConfig {
  final String apiKey;
  final String apiEndpoint;
  final String featureTag;
  final int eventsFlushInterval;

  final int eventsMaxQueueSize;
  final int pollingInterval;
  final int backgroundPollingInterval;
  final String appVersion;
  final bool debugging;

  const BKTConfig._(
      {required this.apiKey,
      required this.apiEndpoint,
      required this.featureTag,
      required this.eventsFlushInterval,
      required this.eventsMaxQueueSize,
      required this.pollingInterval,
      required this.backgroundPollingInterval,
      required this.appVersion,
      required this.debugging});
}

class BKTConfigBuilder {
  String _apiKey = "";
  String _apiEndpoint = "";
  String _featureTag = "";
  int _eventsFlushInterval = 0;
  int _eventsMaxBatchQueueCount = 0;
  int _pollingInterval = 0;
  int _backgroundPollingInterval = 0;
  String _appVersion = "";
  bool _debugging = false;

  BKTConfigBuilder apiKey(String apiKey) {
    _apiKey = apiKey;
    return this;
  }

  BKTConfigBuilder apiEndpoint(String apiEndpoint) {
    _apiEndpoint = apiEndpoint;
    return this;
  }

  BKTConfigBuilder featureTag(String featureTag) {
    _featureTag = featureTag;
    return this;
  }

  BKTConfigBuilder eventsFlushInterval(int eventsFlushInterval) {
    _eventsFlushInterval = eventsFlushInterval;
    return this;
  }

  BKTConfigBuilder eventsMaxQueueSize(int eventsMaxQueueSize) {
    _eventsMaxBatchQueueCount = eventsMaxQueueSize;
    return this;
  }

  BKTConfigBuilder pollingInterval(int pollingInterval) {
    _pollingInterval = pollingInterval;
    return this;
  }

  BKTConfigBuilder backgroundPollingInterval(int backgroundPollingInterval) {
    _backgroundPollingInterval = backgroundPollingInterval;
    return this;
  }

  BKTConfigBuilder appVersion(String appVersion) {
    _appVersion = appVersion;
    return this;
  }

  BKTConfigBuilder debugging(bool debugging) {
    _debugging = debugging;
    return this;
  }

  /// Create an [BKTConfig] from the current builder configuration.
  /// Throws a [ArgumentError] if the `apiKey`, `apiEndpoint`, `appVersion` are empty.
  /// The native SDK will configure the following values by default when it is not set:
  /// `eventsFlushInterval`, `eventsMaxBatchQueueCount`, `pollingInterval`, `backgroundPollingInterval`
  /// Check the documentation for more information
  BKTConfig build() {
    if (_apiKey.isEmpty) {
      throw ArgumentError("apiKey is required");
    }

    if (_apiEndpoint.isEmpty) {
      throw ArgumentError("apiEndpoint is required");
    }

    if (_appVersion.isEmpty) {
      throw ArgumentError("appVersion is required");
    }
    return BKTConfig._(
        apiKey: _apiKey,
        apiEndpoint: _apiEndpoint,
        featureTag: _featureTag,
        eventsFlushInterval: _eventsFlushInterval,
        eventsMaxQueueSize: _eventsMaxBatchQueueCount,
        pollingInterval: _pollingInterval,
        backgroundPollingInterval: _backgroundPollingInterval,
        appVersion: _appVersion,
        debugging: _debugging);
  }
}
