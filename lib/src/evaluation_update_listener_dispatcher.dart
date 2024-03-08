import 'package:flutter/foundation.dart';
import 'evaluation_update_listener.dart';

class EvaluationUpdateListenerDispatcher {
  final _listeners = <String, BKTEvaluationUpdateListener>{};

  EvaluationUpdateListenerDispatcher(Stream<dynamic> eventStream) {
    eventStream.asBroadcastStream().listen(_onEvent);
  }

  void _onEvent(Object? event) {
    _listeners.forEach((key, value) {
      value.onUpdate();
    });
  }

  String addEvaluationUpdateListener(BKTEvaluationUpdateListener listener) {
    final key = UniqueKey().hashCode.toString();
    _listeners[key] = listener;
    return key;
  }

  void removeEvaluationUpdateListener(String key) {
    _listeners.remove(key);
  }

  void clearEvaluationUpdateListeners() {
    _listeners.clear();
  }

  int listenerCount() {
    return _listeners.keys.length;
  }
}
