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
