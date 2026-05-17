import SwiftUI
import FirebaseCore

#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif
#if canImport(FirebaseFunctions)
import FirebaseFunctions
#endif

@main
struct VecationRentalApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var appState = AppState()
    @StateObject private var deepLinkRouter = DeepLinkRouter()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appState)
                .environmentObject(deepLinkRouter)
                .onOpenURL { url in
                    deepLinkRouter.handle(url: url)
                }
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
            configureEmulatorsIfNeeded()
        }
        return true
    }

    private func configureEmulatorsIfNeeded() {
        #if DEBUG
        guard AppConfiguration.useEmulators else { return }
        let host = ProcessInfo.processInfo.environment["FIREBASE_EMULATOR_HOST"] ?? "127.0.0.1"
        #if canImport(FirebaseFirestore)
        Firestore.firestore().useEmulator(withHost: host, port: 8080)
        #endif
        #if canImport(FirebaseFunctions)
        Functions.functions().useEmulator(withHost: host, port: 5001)
        #endif
        #endif
    }
}
