import AppKit
import AVFoundation

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Request microphone access before anything else
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                if granted {
                    self.statusBarController.start()
                } else {
                    self.statusBarController.showPermissionDenied()
                }
            }
        }
        statusBarController = StatusBarController()
    }
}
