import Foundation
import Bucketeer

extension BKTError {
    func mapBKTErrorToErrorCode() -> Int {
        switch self {
        case .redirectRequest(message: _, statusCode: _):
            return 1
        case .badRequest(message: _):
            return 2
        case .unauthorized(message: _):
            return 3
        case .forbidden(message: _):
            return 4
        case .notFound(message: _):
            return 5
        case .clientClosed(message: _):
            return 6
        case .invalidHttpMethod(message: _):
            return 7
        case .payloadTooLarge(message: _):
            return 8
        case .apiServer(message: _):
            return 9
        case .unavailable(message: _):
            return 10
        case .timeout(message: _, error: _, timeoutMillis: _):
            return 11
        case .network(message: _, error: _):
            return 12
        case .illegalArgument(message: _):
            return 13
        case .illegalState(message: _):
            return 14
        case .unknownServer(message: _, error: _, statusCode: _),
             .unknown(message: _, error: _):
            return 15
        }
    }
}

extension Error {
    func toErrorCode() -> Int {
        if let bktError = self as? BKTError {
            return bktError.mapBKTErrorToErrorCode()
        }
        return 0
    }
}
