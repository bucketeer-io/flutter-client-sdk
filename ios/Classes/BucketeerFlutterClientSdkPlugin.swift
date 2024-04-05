import Flutter
import UIKit
import Bucketeer

public class BucketeerFlutterClientSdkPlugin: NSObject, FlutterPlugin {

    private static let METHOD_CHANNEL_NAME = "io.bucketeer.sdk.plugin.flutter"
    private static let EVALUATION_UPDATE_EVENT_CHANNEL_NAME = "\(METHOD_CHANNEL_NAME)::evaluation.update.listener"

    private let logger = BucketeerPluginLogger()
    private let proxyEvaluationListener = BucketeerPluginEvaluationUpdateListener()
    private var proxyEvaluationListenToken: String?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: METHOD_CHANNEL_NAME, binaryMessenger: registrar.messenger())
        let instance = BucketeerFlutterClientSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        let eventChannel = FlutterEventChannel(name: EVALUATION_UPDATE_EVENT_CHANNEL_NAME,
                                               binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance.proxyEvaluationListener)
    }

    private func initialize(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let apiKey = arguments?["apiKey"] as? String else {
            failWithIllegalArgumentException(result: result, message: "apiKey is required")
            return
        }
        guard let apiEndpoint = arguments?["apiEndpoint"] as? String else {
            failWithIllegalArgumentException(result: result, message: "apiEndpoint is required")
            return
        }
        guard let userId = arguments?["userId"] as? String else {
            failWithIllegalArgumentException(result: result, message: "userId is required")
            return
        }
        guard let appVersion = arguments?["appVersion"] as? String else {
            failWithIllegalArgumentException(result: result, message: "appVersion is required")
            return
        }

        let featureTag = (arguments?["featureTag"] as? String) ?? ""

        do {
            var builder = BKTConfig.Builder()
                .with(apiKey: apiKey)
                .with(apiEndpoint: apiEndpoint)
                .with(featureTag: featureTag)
                .with(appVersion: appVersion)

            if let eventsFlushInterval = arguments?["eventsFlushInterval"] as? Int64 {
                builder = builder.with(eventsFlushInterval: eventsFlushInterval)
            }

            if let eventsMaxQueueSize = arguments?["eventsMaxQueueSize"] as? Int {
                builder = builder.with(eventsMaxQueueSize: eventsMaxQueueSize)
            }

            if let pollingInterval = arguments?["pollingInterval"] as? Int64 {
                builder = builder.with(pollingInterval: pollingInterval)
            }

            if let backgroundPollingInterval = arguments?["backgroundPollingInterval"] as? Int64 {
                builder = builder.with(backgroundPollingInterval: backgroundPollingInterval)
            }

            if let debugging = arguments?["debugging"] as? Bool, debugging {
                builder = builder.with(logger: logger)
            }

            let bkConfig = try builder.build()
            let userAttributes = arguments?["userAttributes"] as? [String: String] ?? [:]
            let user = try BKTUser.Builder()
                .with(id: userId)
                .with( attributes: userAttributes)
                .build()

            let completion : ((BKTError?) -> Void) = { [self] err in
                if let er = err {
                    if case .timeout(_, _, _) = err {
                        logger.warn(message: "Fetch evaluations failed during the initialize process. It will try to fetch again in the next polling.")
                    } else {
                        logger.error(message: "BKTClient.initialize failed with error: \(er)", er)
                    }
                    fail(result: result, message: er.localizedDescription, error: er)
                } else {
                    success(result: result)
                }
            }

            if let timeoutMillis = arguments?["timeoutMillis"] as? Int64 {
                try BKTClient.initialize(
                    config: bkConfig, user: user, timeoutMillis: timeoutMillis, completion: completion)
            } else {
                try BKTClient.initialize(config: bkConfig, user: user, completion: completion)
            }

        } catch {
            logger.error(message: "BKTClient.initialize failed with error: \(error)", error)
            fail(result: result, message: error.localizedDescription, error: error)
        }
    }

    private func stringVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let featureId = arguments?["featureId"] as? String else {
            failWithIllegalArgumentException(result: result, message: "featureId is required")
            return
        }
        guard let defaultValue = arguments?["defaultValue"] as? String else {
            failWithIllegalArgumentException(result: result, message: "defaultValue is required")
            return
        }
        do {
            let response = try BKTClient.shared.stringVariation(featureId: featureId, defaultValue: defaultValue)
            success(result: result, response: response)
        } catch {
            fail(result: result, message: error.localizedDescription, error: error)
        }
    }

    private func intVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let featureId = arguments?["featureId"] as? String else {
            failWithIllegalArgumentException(result: result, message: "featureId is required")
            return
        }
        guard let defaultValue = arguments?["defaultValue"] as? Int else {
            failWithIllegalArgumentException(result: result, message: "defaultValue is required")
            return
        }
        do {
            let response = try BKTClient.shared.intVariation(featureId: featureId, defaultValue: defaultValue)
            success(result: result, response: response)
        } catch {
            fail(result: result, message: error.localizedDescription, error: error)
        }
    }

    private func doubleVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let featureId = arguments?["featureId"] as? String else {
            failWithIllegalArgumentException(result: result, message: "featureId is required")
            return
        }
        guard let defaultValue = arguments?["defaultValue"] as? Double else {
            failWithIllegalArgumentException(result: result, message: "defaultValue is required")
            return
        }
        do {
            let response = try BKTClient.shared.doubleVariation(featureId: featureId, defaultValue: defaultValue)
            success(result: result, response: response)
        } catch {
            fail(result: result, message: error.localizedDescription, error: error)
        }
    }

    private func boolVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let featureId = arguments?["featureId"] as? String else {
            failWithIllegalArgumentException(result: result, message: "featureId is required")
            return
        }
        guard let defaultValue = arguments?["defaultValue"] as? Bool else {
            failWithIllegalArgumentException(result: result, message: "defaultValue is required")
            return
        }
        do {
            let response = try BKTClient.shared.boolVariation(featureId: featureId, defaultValue: defaultValue)
            success(result: result, response: response)
        } catch {
            fail(result: result, message: error.localizedDescription, error: error)
        }
    }

    private func track(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let goalId = arguments?["goalId"] as? String else {
            failWithIllegalArgumentException(result: result, message: "goalId is required")
            return
        }
        do {
            if let value = arguments?["value"] as? Double {
                try BKTClient.shared.track(goalId: goalId, value: value)
            } else {
                try BKTClient.shared.track(goalId: goalId)
            }
            success(result: result)
        } catch {
            fail(result: result, message: error.localizedDescription, error: error)
        }
    }

    private func jsonVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let featureId = arguments?["featureId"] as? String else {
            failWithIllegalArgumentException(result: result, message: "featureId is required")
            return
        }
        guard let defaultValue = arguments?["defaultValue"] as? [String: AnyHashable] else {
            failWithIllegalArgumentException(result: result, message: "defaultValue is required")
            return
        }
        do {
            let response = try BKTClient.shared.jsonVariation(featureId: featureId, defaultValue: defaultValue)
            success(result: result, response: response)
        } catch {
            fail(result: result, message: error.localizedDescription, error: error)
        }
    }

    private func currentUser(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        var client: BKTClient
        do {
            client = try BKTClient.shared
        } catch {
            fail(result: result, message: error.localizedDescription, error: error)
            return
        }

        guard let user = client.currentUser() else {
            let message = "Failed to fetch the user"
            let err = BKTError.illegalState(message: message)
            fail(result: result, message: message, error: err)
            return
        }
        success(result: result, response: ["id": user.id, "data": user.attr])
    }

    private func updateUserAttributes(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let userAttributes = arguments as? [String: String] else {
            failWithIllegalArgumentException(result: result, message: "userAttributes is required")
            return
        }
        do {
            try BKTClient.shared.updateUserAttributes(attributes: userAttributes)
            success(result: result)
        } catch {
            fail(result: result, message: error.localizedDescription, error: error)
        }
    }

    private func fetchEvaluations(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        let timeoutMillis = arguments?["timeoutMillis"] as? Int64
        do {
            try BKTClient.shared.fetchEvaluations(timeoutMillis: timeoutMillis) { [weak self] err in
                if let err {
                    self?.fail(result: result, message: err.localizedDescription, error: err)
                } else {
                    self?.success(result: result)
                }
            }
        } catch {
            fail(result: result, message: error.localizedDescription, error: error)
        }
    }

    private func flush(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        do {
            try BKTClient.shared.flush {[weak self] error in
                if let bktError = error {
                    let errorMessage = bktError.localizedDescription
                    self?.fail(result: result, message: errorMessage, error: bktError)
                } else {
                    self?.success(result: result)
                }
            }
        } catch {
            fail(result: result, message: error.localizedDescription, error: error)
        }
    }

    private func evaluationDetails(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let featureId = arguments?["featureId"] as? String else {
            failWithIllegalArgumentException(result: result, message: "featureId is required")
            return
        }
        var client: BKTClient?
        do {
            client = try BKTClient.shared
        } catch {
            fail(result: result, message: error.localizedDescription, error: error)
            return
        }

        guard let response = client?.evaluationDetails(featureId: featureId) else {
            let message = "Feature flag not found"
            let err = BKTError.notFound(message: message)
            fail(result: result, message: message, error: err)
            return
        }
        success(
            result: result,
            response: [
                "id": response.id,
                "featureId": response.featureId,
                "featureVersion": response.featureVersion,
                "userId": response.userId,
                "variationId": response.variationId,
                "variationName": response.variationName,
                "variationValue": response.variationValue,
                "reason": response.reason.rawValue
            ])
    }

    private func addProxyEvaluationUpdateListener(_ result: @escaping FlutterResult) {
        do {
            if let listenToken = proxyEvaluationListenToken {
                success(result: result, response: listenToken)
            } else {
                let newListenToken = try BKTClient.shared.addEvaluationUpdateListener(listener: proxyEvaluationListener)
                proxyEvaluationListenToken = newListenToken
                success(result: result, response: newListenToken)
            }
        } catch {
            fail(result: result, message: error.localizedDescription, error: error)
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        let arguments = call.arguments as? [String: Any]
        let callMethod = BKTFlutterCallMethod(rawValue: call.method) ?? .unknown
        switch callMethod {
        case .initialize:
            initialize(arguments, result)

        case .stringVariation:
            stringVariation(arguments, result)

        case .intVariation:
            intVariation(arguments, result)

        case .doubleVariation:
            doubleVariation(arguments, result)

        case .boolVariation:
            boolVariation(arguments, result)

        case .track:
            track(arguments, result)

        case .jsonVariation:
            jsonVariation(arguments, result)

        case .currentUser:
            currentUser(arguments, result)

        case .updateUserAttributes:
            updateUserAttributes(arguments, result)

        case .fetchEvaluations:
            fetchEvaluations(arguments, result)

        case .flush:
            flush(arguments, result)

        case .evaluationDetails:
            evaluationDetails(arguments, result)

        case .addProxyEvaluationUpdateListener:
            // Note: It will only handle in the Flutter side. We don't implement native code for these methods
            // See: BucketeerPluginEvaluationUpdateListener.swift
            addProxyEvaluationUpdateListener(result)

        case .destroy:
            do {
                if let listenToken = proxyEvaluationListenToken {
                    try BKTClient.shared.removeEvaluationUpdateListener(key: listenToken)
                    proxyEvaluationListenToken = nil
                }
                try BKTClient.destroy()
                success(result: result)
            } catch {
                fail(result: result, message: error.localizedDescription, error: error)
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    func success(result: @escaping FlutterResult, response: Any? = nil) {
        let dic = [
            "status": true,
            "response": response
        ] as [String: Any?]
        result(dic)
    }

    func fail(result: @escaping FlutterResult, message: String = "", error: Error? = nil) {
        let errorCode = error?.toErrorCode() ?? 0
        let dic = [
            "status": false,
            "errorMessage": message,
            "errorCode": errorCode,
        ] as [String: Any]
        result(dic)
    }

    func failWithIllegalArgumentException(result: @escaping FlutterResult, message: String = "") {
        let err = BKTError.illegalArgument(message: message)
        fail(result: result, message: err.errorDescription ?? "", error: err)
    }
}
