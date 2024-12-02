import AppKit
import ArgumentParser
import Foundation

struct PlayPause: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Toggle play/pause"
    )

    func run() throws {
        try! Player.action(.toggle_play_pause)
    }
}
