import Foundation
import Bucketeer

class BucketeerPluginLogger : BKTLogger {
    func debug(message: String) {
        debugPrint("BucketeerPluginLogger__DEBUG__ \(message)")
    }
    
    func warn(message: String) {
        debugPrint("BucketeerPluginLogger__WARN__ \(message)")
    }
    
    func error(_ error: Error) {
        debugPrint("BucketeerPluginLogger__ERROR__ \(error)")
    }
}
