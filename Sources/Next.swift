import AppKit
import ArgumentParser
import Foundation

struct Next: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Play next track"
    )

    func run() throws {
        try! Player.action(.next)
    }
}
