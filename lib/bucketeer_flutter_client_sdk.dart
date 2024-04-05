library bucketeer;

export 'src/evaluation.dart';
export 'src/user.dart';
export 'src/result.dart';
export 'src/evaluation_update_listener.dart';
export 'src/config.dart';
export 'src/exception.dart';

import 'src/native_channel_result_parser.dart';
import 'src/exception_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'bucketeer_flutter_client_sdk.dart';
import 'src/proxy_evaluation_update_listener.dart';
import 'src/call_methods.dart';
import 'src/constants.dart';
import 'src/evaluation_update_listener_dispatcher.dart';

/// Bucketeer Flutter SDK
class BKTClient {
  const BKTClient._();

  static const BKTClient instance = BKTClient._();

  static const MethodChannel _channel =
      MethodChannel(Constants.methodChannelName);
  static const EventChannel _eventChannel =
      EventChannel(Constants.eventChannelName);
  static final EvaluationUpdateListenerDispatcher _dispatcher =
      EvaluationUpdateListenerDispatcher(
          _eventChannel.receiveBroadcastStream());

  static Future<BKTResult<void>> initialize({
    required BKTConfig config,
    required BKTUser user,
    int? timeoutMillis,
  }) async {
    var rs = await instance._invokeMethod(
      CallMethods.initialize.name,
      argument: {
        'apiKey': config.apiKey,
        'apiEndpoint': config.apiEndpoint,
        'featureTag': config.featureTag,
        'debugging': config.debugging,
        'eventsFlushInterval': config.eventsFlushInterval,
        'eventsMaxQueueSize': config.eventsMaxQueueSize,
        'pollingInterval': config.pollingInterval,
        'backgroundPollingInterval': config.backgroundPollingInterval,
        'appVersion': config.appVersion,
        'timeoutMillis': timeoutMillis,
        'userId': user.id,
        'userAttributes': user.attributes,
      },
    );
    // The native code might emit a `BKTException`,
    // so we must use `BKTResult` to handle the exceptions
    return statusGuard(rs);
  }

  Future<String> stringVariation(
    String featureId, {
    required String defaultValue,
  }) async {
    return valueGuard<String>(
      await _invokeMethod(
        CallMethods.stringVariation.name,
        argument: {
          'featureId': featureId,
          'defaultValue': defaultValue,
        },
      ),
    ).onError((error, stackTrace) {
      debugPrint("get stringVariation fail: ${error?.toString()}");
      return defaultValue;
    });
  }

  Future<int> intVariation(
    String featureId, {
    required int defaultValue,
  }) async {
    return valueGuard<int>(
      await _invokeMethod(
        CallMethods.intVariation.name,
        argument: {
          'featureId': featureId,
          'defaultValue': defaultValue,
        },
      ),
    ).onError((error, stackTrace) {
      debugPrint("get intVariation fail: ${error?.toString()}");
      return defaultValue;
    });
  }

  Future<double> doubleVariation(
    String featureId, {
    required double defaultValue,
  }) async {
    return valueGuard<double>(
      await _invokeMethod(
        CallMethods.doubleVariation.name,
        argument: {
          'featureId': featureId,
          'defaultValue': defaultValue,
        },
      ),
    ).onError((error, stackTrace) {
      debugPrint("get doubleVariation fail: ${error?.toString()}");
      return defaultValue;
    });
  }

  Future<bool> boolVariation(
    String featureId, {
    required bool defaultValue,
  }) async {
    return valueGuard<bool>(
      await _invokeMethod(
        CallMethods.boolVariation.name,
        argument: {
          'featureId': featureId,
          'defaultValue': defaultValue,
        },
      ),
    ).onError((error, stackTrace) {
      debugPrint("get boolVariation fail: ${error?.toString()}");
      return defaultValue;
    });
  }

  Future<Map<String, dynamic>> jsonVariation(
    String featureId, {
    required Map<String, dynamic> defaultValue,
  }) async {
    return valueGuard<Map<String, dynamic>>(
      await _invokeMethod(
        CallMethods.jsonVariation.name,
        argument: {
          'featureId': featureId,
          'defaultValue': defaultValue,
        },
      ),
      customMapping: (response) {
        return response;
      },
    ).onError((error, stackTrace) {
      debugPrint("get jsonVariation fail: ${error?.toString()}");
      return defaultValue;
    });
  }

  Future<BKTResult<void>> track(
    String goalId, {
    double? value,
  }) async {
    return await statusGuard(
      await _invokeMethod(
        CallMethods.track.name,
        argument: {
          'goalId': goalId,
          'value': value,
        },
      ),
    ).onError((Object error, stackTrace) {
      debugPrint("track fail: ${error.toString()}");
      return error.toBKTResultFailure();
    });
  }

  Future<BKTResult<BKTUser>> currentUser() async {
    return valueGuard<BKTUser>(
      await _invokeMethod(CallMethods.currentUser.name),
      customMapping: (response) {
        return BKTUserBuilder()
            .id(response['id'])
            .customAttributes(
              Map<String, String>.from(response['data']),
            )
            .build();
      },
    )
        .then((value) => BKTResult.success(data: value))
        .onError((Object error, stackTrace) {
      debugPrint("get currentUser fail: ${error.toString()}");
      return error.toBKTResultFailure();
    });
  }

  Future<BKTResult<void>> updateUserAttributes(
      Map<String, String> userAttributes) async {
    return await statusGuard(
      await _invokeMethod(
        CallMethods.updateUserAttributes.name,
        argument: userAttributes,
      ),
    ).onError((Object error, stackTrace) {
      debugPrint("updateUserAttributes fail: ${error.toString()}");
      return error.toBKTResultFailure();
    });
  }

  Future<BKTResult<void>> fetchEvaluations({int? timeoutMillis}) async {
    /// The native code may emit `BKTException`, so we must use `BKTResult` for handle exception
    return statusGuard(
      await _invokeMethod(
        CallMethods.fetchEvaluations.name,
        argument: {
          'timeoutMillis': timeoutMillis,
        },
      ),
    );
  }

  Future<BKTResult<void>> flush() async {
    /// The native code may emit `BKTException`, so we must use `BKTResult` for handle exception
    return statusGuard(
      await _invokeMethod(CallMethods.flush.name),
    );
  }

  Future<BKTResult<void>> destroy() async {
    return await statusGuard(
      await _invokeMethod(CallMethods.destroy.name).then(
        (value) async {
          /// Remove all listener for the current client
          ProxyEvaluationUpdateListenToken.clearToken();
          clearEvaluationUpdateListeners();
          return value;
        },
      ),
    ).onError((Object error, stackTrace) {
      debugPrint("destroy fail: ${error.toString()}");
      return error.toBKTResultFailure();
    });
  }

  Future<BKTEvaluation?> evaluationDetails(String featureId) async {
    return valueGuard<BKTEvaluation?>(
      await _invokeMethod(CallMethods.evaluationDetails.name, argument: {
        'featureId': featureId,
      }),
      customMapping: (response) {
        return BKTEvaluation(
          id: response['id'],
          featureId: response['featureId'],
          featureVersion: response['featureVersion'],
          userId: response['userId'],
          variationId: response['variationId'],
          variationName: response['variationName'],
          variationValue: response['variationValue'],
          reason: response['reason'],
        );
      },
    ).onError((error, stackTrace) {
      /// Feature flag not found.
      debugPrint("get evaluationDetails fail: ${error?.toString()}");
      return null;
    });
  }

  Future<String?> _addProxyEvaluationUpdateListener() async {
    return valueGuard<String?>(
      await _invokeMethod(
        CallMethods.addProxyEvaluationUpdateListener.name,
        argument: {},
      ),
    ).onError((error, stackTrace) {
      debugPrint(
          "_addProxyEvaluationUpdateListener fail: ${error?.toString()}");
      return null;
    });
  }

  Future<void> _checkProxyListenerReady() async {
    /// Create a new listener if needed
    if (ProxyEvaluationUpdateListenToken.getToken() == null) {
      await _addProxyEvaluationUpdateListener().then((value) {
        if (value != null) {
          ProxyEvaluationUpdateListenToken.setToken(value);
        }
      });
    }
  }

  Future<String> addEvaluationUpdateListener(
      BKTEvaluationUpdateListener listener) async {
    await _checkProxyListenerReady();
    return _dispatcher.addEvaluationUpdateListener(listener);
  }

  void removeEvaluationUpdateListener(String key) {
    _dispatcher.removeEvaluationUpdateListener(key);
  }

  void clearEvaluationUpdateListeners() {
    _dispatcher.clearEvaluationUpdateListeners();
  }

  Future<Map<String, dynamic>> _invokeMethod(
    String method, {
    Map<String, dynamic> argument = const {},
  }) async {
    try {
      return Map<String, dynamic>.from(
        await _channel.invokeMapMethod(method, argument) ?? {},
      );
    } catch (ex) {
      /// Default runtime error catching
      return {
        "status": false,
        "errorMessage": ex.toString(),
      };
    }
  }
}
