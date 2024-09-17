import Foundation
import Bucketeer

extension String {
    func jsonStringToBKTValue() -> BKTValue {
        let value = self
        let data = value.data(using: .utf8) ?? Data()
        if let valueResult = (try? JSONDecoder().decode(BKTValue.self, from: data)), valueResult != .null {
            return valueResult
        }
        return .string(self)
    }
}

extension BKTValue {
    func toJson() -> Any {
        switch self {
        case .boolean(let value):
            return value
        case .string(let value):
            return value
        case .number(let value):
            return value
        case .list(let value):
            return value.map { $0.toJson() }
        case .dictionary(let value):
            return value.mapValues { $0.toJson() }
        case .null:
            return NSNull()
        }
    }
}
