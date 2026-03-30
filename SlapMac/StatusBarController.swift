import AppKit
import Combine

final class StatusBarController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let slapDetector = SlapDetector()
    private let soundPlayer = SoundPlayer()
    private var statusMenuItem: NSMenuItem!
    private var enabledMenuItem: NSMenuItem!

    init() {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "hand.raised.fill", accessibilityDescription: "SlapMac")
        }
        buildMenu()
    }

    func start() {
        slapDetector.onSlapDetected = { [weak self] in
            self?.handleSlap()
        }
        slapDetector.start()
        statusMenuItem?.title = "👂 Listening..."
    }

    func showPermissionDenied() {
        statusMenuItem?.title = "⚠️ Microphone access denied"
    }

    // MARK: - Private

    private func handleSlap() {
        soundPlayer.playRandom()
        // Brief visual flash on the menu bar icon
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "hand.raised.slash.fill", accessibilityDescription: "Slap!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                button.image = NSImage(systemSymbolName: "hand.raised.fill", accessibilityDescription: "SlapMac")
            }
        }
    }

    private func buildMenu() {
        let menu = NSMenu()

        statusMenuItem = NSMenuItem(title: "Starting...", action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)

        menu.addItem(.separator())

        // Enabled toggle
        enabledMenuItem = NSMenuItem(title: "Enabled", action: #selector(toggleEnabled), keyEquivalent: "e")
        enabledMenuItem.target = self
        enabledMenuItem.state = .on
        menu.addItem(enabledMenuItem)

        menu.addItem(.separator())

        // Sensitivity slider
        let sliderItem = NSMenuItem()
        let sliderView = SensitivitySliderView(frame: NSRect(x: 0, y: 0, width: 220, height: 50))
        sliderView.onValueChanged = { [weak self] value in
            // Slider goes 0 (low sensitivity) to 1 (high sensitivity)
            // Map to threshold: high sensitivity = low threshold
            let threshold = 0.30 - value * 0.27  // range: 0.03 .. 0.30
            self?.slapDetector.threshold = threshold
        }
        // Initialize slider from current threshold
        let initialSensitivity = (0.30 - slapDetector.threshold) / 0.27
        sliderView.setValue(initialSensitivity)
        sliderItem.view = sliderView
        menu.addItem(sliderItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit SlapMac", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    @objc private func toggleEnabled() {
        if enabledMenuItem.state == .on {
            enabledMenuItem.state = .off
            slapDetector.stop()
            statusMenuItem.title = "⏸ Paused"
        } else {
            enabledMenuItem.state = .on
            slapDetector.start()
            statusMenuItem.title = "👂 Listening..."
        }
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}

// MARK: - Sensitivity Slider View

private final class SensitivitySliderView: NSView {
    var onValueChanged: ((Double) -> Void)?
    private let slider = NSSlider()
    private let label = NSTextField(labelWithString: "Sensitivity")

    override init(frame: NSRect) {
        super.init(frame: frame)

        label.font = .systemFont(ofSize: 11)
        label.textColor = .secondaryLabelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        slider.minValue = 0
        slider.maxValue = 1
        slider.doubleValue = 0.5
        slider.target = self
        slider.action = #selector(sliderChanged)
        slider.translatesAutoresizingMaskIntoConstraints = false
        addSubview(slider)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            slider.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 4),
            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            slider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func setValue(_ value: Double) {
        slider.doubleValue = value
    }

    @objc private func sliderChanged() {
        onValueChanged?(slider.doubleValue)
    }
}
