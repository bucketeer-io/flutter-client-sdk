import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:mocktail/mocktail.dart';

extension InitializeSuccess on BKTResult<void> {
  bool isInitializeSuccess() {
    return isSuccess || asFailure.exception is BKTTimeoutException;
  }
}

extension E2EBKTClient on BKTClient {
  /// This func will retry the BKTClient.initialize 3 times (default) if we got a network error.
  static Future<BKTResult<void>> initializeWithRetryMechanism({
    required BKTConfig config,
    required BKTUser user,
    int? timeoutMillis,
    int maxRetryTimes = 3,
  }) async {
    var retryCount = 0;
    BKTResult<void>? result;
    do {
      result = await BKTClient.initialize(
        config: config,
        user: user,
        timeoutMillis: timeoutMillis,
      );
      bool shouldRetry =
          result.isFailure && result.asFailure is BKTNetworkException;
      if (shouldRetry) {
        retryCount++;
        continue;
      }
      break;
    } while (retryCount < maxRetryTimes);
    return result;
  }
}

class MockEvaluationUpdateListener extends Mock
    implements BKTEvaluationUpdateListener {}

bool assertEvaluationDetails<T extends Object>({
  required BKTEvaluationDetails<T> actual,
  required BKTEvaluationDetails<T> expected,
}) {
  return actual.featureId == expected.featureId &&
      actual.featureVersion == expected.featureVersion &&
      actual.userId == expected.userId &&
      actual.variationId == expected.variationId &&
      actual.variationName == expected.variationName &&
      actual.reason == expected.reason &&
      actual.variationValue == expected.variationValue;
}
