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
    
    private func boolVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let context : VariationRequestContext<Bool> = requiredVariationContext(arguments, result) else { return }
        
        let response = context.client.boolVariation(featureId: context.featureId, defaultValue: context.defaultValue)
        success(result: result, response: response)
    }
    
    private func boolVariationDetails(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let context : VariationRequestContext<Bool> = requiredVariationContext(arguments, result) else { return }
        
        let response = context.client.boolVariationDetails(featureId: context.featureId, defaultValue: context.defaultValue)
        success(
            result: result,
            response: response.toDictionary())
    }
    
    private func stringVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let context : VariationRequestContext<String> = requiredVariationContext(arguments, result) else { return }
        
        let response = context.client.stringVariation(featureId: context.featureId, defaultValue: context.defaultValue)
        success(result: result, response: response)
    }
    
    private func stringVariationDetails(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let context : VariationRequestContext<String> = requiredVariationContext(arguments, result) else { return }
        
        let response = context.client.stringVariationDetails(featureId: context.featureId, defaultValue: context.defaultValue)
        success(
            result: result,
            response: response.toDictionary())
    }
    
    private func intVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let context : VariationRequestContext<Int> = requiredVariationContext(arguments, result) else { return }
        
        let response = context.client.intVariation(featureId: context.featureId, defaultValue: context.defaultValue)
        success(result: result, response: response)
    }
    
    private func intVariationDetails(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let context : VariationRequestContext<Int> = requiredVariationContext(arguments, result) else { return }
        
        let response = context.client.intVariationDetails(featureId: context.featureId, defaultValue: context.defaultValue)
        success(
            result: result,
            response: response.toDictionary())
    }
    
    private func doubleVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let context : VariationRequestContext<Double> = requiredVariationContext(arguments, result) else { return }
        
        let response = context.client.doubleVariation(featureId: context.featureId, defaultValue: context.defaultValue)
        success(result: result, response: response)
    }
    
    private func doubleVariationDetails(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let context : VariationRequestContext<Double> = requiredVariationContext(arguments, result) else { return }
        
        let response = context.client.doubleVariationDetails(featureId: context.featureId, defaultValue: context.defaultValue)
        success(
            result: result,
            response: response.toDictionary())
    }
    
    private func objectVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let context : VariationRequestContext<String> = requiredVariationContext(arguments, result) else { return }
        
        let response = context.client.objectVariation(featureId: context.featureId, defaultValue: context.defaultValue.jsonStringToBKTValue())
        success(result: result, response: response)
    }
    
    private func objectVariationDetails(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let context : VariationRequestContext<String> = requiredVariationContext(arguments, result) else { return }
  
        let response = context.client.objectVariationDetails(featureId: context.featureId, defaultValue: context.defaultValue.jsonStringToBKTValue())
        success(
            result: result,
            response: response.toDictionary())
    }
    
    @available(*, deprecated, message: "will remove it after the iOS native SDK remove it")
    private func jsonVariation(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let context : VariationRequestContext<[String: AnyHashable]> = requiredVariationContext(arguments, result) else { return }
        
        let response = context.client.jsonVariation(featureId: context.featureId, defaultValue: context.defaultValue)
        success(result: result, response: response)
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
    
    @available(*, deprecated, message: "will remove it after the iOS native SDK remove it")
    private func evaluationDetails(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) {
        guard let featureId = arguments?[BKTFlutterCallParams.featureId] as? String else {
            failParamFeatureIdRequired(result: result)
            return
        }
        guard let client = try? BKTClient.shared else {
            failClientIsNotInitialized(result: result)
            return
        }
        
        guard let response = client.evaluationDetails(featureId: featureId) else {
            failBecauseFeatureFlagNotFound(result: result)
            return
        }
        
        success(
            result: result,
            response: [
                "id": response.id,
                BKTFlutterCallParams.featureId: response.featureId,
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
            
        case .boolVariation:
            boolVariation(arguments, result)
            
        case .boolVariationDetails:
            boolVariationDetails(arguments, result)
            
        case .intVariation:
            intVariation(arguments, result)
            
        case .intVariationDetails:
            intVariationDetails(arguments, result)
            
        case .doubleVariation:
            doubleVariation(arguments, result)
            
        case .doubleVariationDetails:
            doubleVariationDetails(arguments, result)
            
        case .stringVariation:
            stringVariation(arguments, result)
            
        case .stringVariationDetails:
            stringVariationDetails(arguments, result)
            
        case .objectVariation:
            objectVariation(arguments, result)
            
        case .objectVariationDetails:
            objectVariationDetails(arguments, result)
            
        case .jsonVariation:
            jsonVariation(arguments, result)
            
        case .evaluationDetails:
            evaluationDetails(arguments, result)
            
        case .track:
            track(arguments, result)
            
        case .currentUser:
            currentUser(arguments, result)
            
        case .updateUserAttributes:
            updateUserAttributes(arguments, result)
            
        case .fetchEvaluations:
            fetchEvaluations(arguments, result)
            
        case .flush:
            flush(arguments, result)
            
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
    
    func failParamFeatureIdRequired(result: @escaping FlutterResult) {
        failWithIllegalArgumentException(result: result, message: "featureId is required")
    }
    
    func failParamDefaultValueRequired(result: @escaping FlutterResult) {
        failWithIllegalArgumentException(result: result, message: "defaultValue is required")
    }
    
    func failClientIsNotInitialized(result: @escaping FlutterResult) {
        let err = BKTError.illegalState(message: "BKTClient is not initialized")
        fail(result: result, message: err.errorDescription ?? "", error: err)
    }
    
    func failBecauseFeatureFlagNotFound(result: @escaping FlutterResult) {
        let message = "Feature flag not found"
        let err = BKTError.notFound(message: message)
        fail(result: result, message: message, error: err)
    }
    

    private func requiredVariationContext<T>(_ arguments: [String: Any]?, _ result: @escaping FlutterResult) -> VariationRequestContext<T>? {
        guard let featureId = arguments?[BKTFlutterCallParams.featureId] as? String else {
            failParamFeatureIdRequired(result: result)
            return nil
        }
        guard let defaultValue = arguments?[BKTFlutterCallParams.defaultValue] as? T else {
            failWithIllegalArgumentException(result: result)
            return nil
        }
        guard let client = try? BKTClient.shared else {
            failClientIsNotInitialized(result: result)
            return nil
        }
        return VariationRequestContext(featureId: featureId, defaultValue: defaultValue, client: client)
    }
}

class VariationRequestContext<T>{
    internal init(featureId: String, defaultValue: T, client: BKTClient) {
        self.featureId = featureId
        self.defaultValue = defaultValue
        self.client = client
    }
    
    let featureId: String
    let defaultValue: T
    let client: BKTClient
}

extension BKTEvaluationDetails where T: Equatable {
    func toDictionary() -> [String: Any] {
        [
            "featureId": featureId,
            "featureVersion": featureVersion,
            "userId": userId,
            "variationId": variationId,
            "variationName": variationName,
            "variationValue": variationValue,
            "reason": reason.rawValue
        ]
    }
}
