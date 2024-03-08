import Foundation
import Flutter
import Bucketeer

class BucketeerPluginEvaluationUpdateListener: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}

extension BucketeerPluginEvaluationUpdateListener: EvaluationUpdateListener {
    func onUpdate() {
        if let eventBus = eventSink {
            eventBus(true)
        }
    }
}
