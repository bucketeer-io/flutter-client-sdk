import Foundation

public enum BKTFlutterCallMethod: String, Codable, Hashable {
    case initialize = "initialize"
    case stringVariation = "stringVariation"
    case intVariation = "intVariation"
    case doubleVariation = "doubleVariation"
    case boolVariation = "boolVariation"
    case jsonVariation = "jsonVariation"
    case track = "track"
    case currentUser = "currentUser"
    case updateUserAttributes = "updateUserAttributes"
    case fetchEvaluations = "fetchEvaluations"
    case flush = "flush"
    case evaluationDetails = "evaluationDetails"
    case addEvaluationUpdateListener = "addEvaluationUpdateListener"
    case removeEvaluationUpdateListener = "removeEvaluationUpdateListener"
    case clearEvaluationUpdateListeners = "clearEvaluationUpdateListeners"
    case destroy = "destroy"
    case unknown = "unknown"
}
