import AVFoundation
import Accelerate

final class SlapDetector {
    /// Detection threshold — lower = more sensitive.
    /// Range: ~0.03 (very sensitive) to ~0.30 (hard slap only).
    var threshold: Double = 0.40

    /// Called on the main thread when a slap is detected.
    var onSlapDetected: (() -> Void)?

    private let engine = AVAudioEngine()
    private var smoothedRMS: Float = 0
    private let smoothingAlpha: Float = 0.05  // slow-moving average
    private var lastDetectionTime: Date = .distantPast
    private let cooldownInterval: TimeInterval = 0.6  // seconds between triggers
    private var isRunning = false

    func start() {
        guard !isRunning else { return }

        let inputNode = engine.inputNode
        let format = inputNode.outputFormat(forBus: 0)

        // Reset state
        smoothedRMS = 0

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, _ in
            self?.processBuffer(buffer)
        }

        do {
            try engine.start()
            isRunning = true
        } catch {
            print("SlapDetector: failed to start audio engine: \(error)")
        }
    }

    func stop() {
        guard isRunning else { return }
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        isRunning = false
    }

    // MARK: - Signal Processing

    private func processBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }

        let frameCount = Int(buffer.frameLength)
        let samples = channelData[0]

        // Compute RMS of this buffer using Accelerate
        var rms: Float = 0
        vDSP_rmsqv(samples, 1, &rms, vDSP_Length(frameCount))

        // High-pass filter on the amplitude envelope:
        // smoothedRMS tracks the slow-moving ambient level.
        // A slap produces a sharp spike where currentRMS >> smoothedRMS.
        let delta = rms - smoothedRMS

        // Update the running average (do this AFTER computing delta)
        smoothedRMS = smoothingAlpha * rms + (1 - smoothingAlpha) * smoothedRMS

        // Check for spike above threshold
        if delta > Float(threshold) {
            let now = Date()
            if now.timeIntervalSince(lastDetectionTime) > cooldownInterval {
                lastDetectionTime = now
                DispatchQueue.main.async { [weak self] in
                    self?.onSlapDetected?()
                }
            }
        }
    }
}
