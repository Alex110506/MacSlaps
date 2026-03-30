import AppKit
import AVFoundation

final class SoundPlayer {
    private var players: [AVAudioPlayer] = []
    private var lastIndex: Int?

    private static let soundFileNames = [
        "groan-female-long-epic-stock-media-1-00-00",
        "moan-pleasure-female-epic-stock-media-1-00-00",
        "moan-soft-short-female-smartsound-fx-1-1-00-00",
    ]

    init() {
        for name in Self.soundFileNames {
            guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else {
                print("SoundPlayer: missing bundle resource \(name).wav")
                continue
            }
            do {
                let player = try AVAudioPlayer(contentsOf: url)
                player.prepareToPlay()
                players.append(player)
            } catch {
                print("SoundPlayer: failed to load \(name).wav: \(error)")
            }
        }

        if players.isEmpty {
            print("SoundPlayer: no sounds loaded, falling back to system beep")
        }
    }

    func playRandom() {
        if players.isEmpty {
            NSSound.beep()
            return
        }
        var index: Int
        repeat {
            index = Int.random(in: 0..<players.count)
        } while index == lastIndex && players.count > 1
        lastIndex = index
        let player = players[index]
        player.currentTime = 0
        player.play()
    }
}
