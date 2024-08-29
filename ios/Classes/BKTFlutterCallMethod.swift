import Foundation

enum BKTFlutterCallMethod: String, Codable, Hashable {
    case initialize

    case track
    case currentUser
    case updateUserAttributes
    case fetchEvaluations
    case flush
   
    case addProxyEvaluationUpdateListener
    case destroy
    case unknown
    
    case stringVariation
    case stringVariationDetails
    
    case intVariation
    case intVariationDetails
    
    case doubleVariation
    case doubleVariationDetails
    
    case boolVariation
    case boolVariationDetails
    
    case objectVariation
    case objectVariationDetails
    
    case jsonVariation
    case evaluationDetails
}

class BKTFlutterCallParams {
    static let featureId = "featureId"
    static let defaultValue = "defaultValue"
}

