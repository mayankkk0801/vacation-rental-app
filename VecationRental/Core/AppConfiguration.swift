import Foundation

enum AppConfiguration {
    static var useEmulators: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["USE_FIREBASE_EMULATORS"] == "1"
        #else
        false
        #endif
    }
}
