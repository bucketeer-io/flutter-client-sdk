import Foundation

enum BKTFlutterCallMethod: String, Codable, Hashable {
    case initialize
    case stringVariation
    case intVariation
    case doubleVariation
    case boolVariation
    case jsonVariation
    case track
    case currentUser
    case updateUserAttributes
    case fetchEvaluations
    case flush
    case evaluationDetails
    case addProxyEvaluationUpdateListener
    case destroy
    case unknown
    
    case stringVariationDetails
    case intVariationDetails
    case doubleVariationDetails
    case boolVariationDetails
    case jsonVariationDetails
}

class BKTFlutterCallParams {
    static let featureId = "featureId"
    static let defaultValue = "defaultValue"
}

