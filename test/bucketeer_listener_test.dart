import 'dart:async';

import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:bucketeer_flutter_client_sdk/src/evaluation_update_listener_dispatcher.dart';
import 'package:bucketeer_flutter_client_sdk/src/proxy_evaluation_update_listener.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockEvaluationUpdateListener extends Mock
    implements BKTEvaluationUpdateListener {}

void main() {
  final eventController = StreamController<bool>.broadcast();

  test('ProxyEvaluationUpdateListenToken tests', () async {
    expect(ProxyEvaluationUpdateListenToken.getToken(), null);
    ProxyEvaluationUpdateListenToken.setToken("token001");
    expect(ProxyEvaluationUpdateListenToken.getToken(), "token001");
    ProxyEvaluationUpdateListenToken.clearToken();
    expect(ProxyEvaluationUpdateListenToken.getToken(), null);
    ProxyEvaluationUpdateListenToken.setToken("token002");
    expect(ProxyEvaluationUpdateListenToken.getToken(), "token002");
  });

  test('EvaluationUpdateListener tests', () async {
    final dispatcher =
        EvaluationUpdateListenerDispatcher(eventController.stream);
    final mockListener = MockEvaluationUpdateListener();
    final neverCalledMockListener = MockEvaluationUpdateListener();
    final listenToken = dispatcher.addEvaluationUpdateListener(mockListener);
    expect(listenToken.isNotEmpty, true);
    expect(dispatcher.listenerCount(), 1);

    /// Send 3 events
    eventController.add(true);
    eventController.add(true);
    eventController.add(true);

    /// Wait 50ms because the stream is async
    await Future.delayed(const Duration(milliseconds: 50));
    verify(() => mockListener.onUpdate()).called(3);

    dispatcher.removeEvaluationUpdateListener(listenToken);
    expect(dispatcher.listenerCount(), 0);

    dispatcher.addEvaluationUpdateListener(mockListener);
    dispatcher.addEvaluationUpdateListener(neverCalledMockListener);
    expect(dispatcher.listenerCount(), 2);

    /// Remove all update listeners
    dispatcher.clearEvaluationUpdateListeners();
    expect(dispatcher.listenerCount(), 0);

    /// Send 4 new events
    eventController.add(true);
    eventController.add(true);
    eventController.add(true);
    eventController.add(true);

    /// Wait 50ms because the stream is async
    await Future.delayed(const Duration(milliseconds: 50));

    /// The neverCalledMockListener is removed before any update is sent
    /// so that, it won't get any update
    verifyNever(() => neverCalledMockListener.onUpdate());

    /// The same with mockListener
    verifyNever(() => mockListener.onUpdate());
  });
}
