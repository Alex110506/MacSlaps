import SwiftUI

@main
struct SlapMacApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // No windows — this is a menu-bar-only agent app
        Settings { EmptyView() }
    }
}
