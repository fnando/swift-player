import AppKit
import ArgumentParser
import Foundation

struct Play: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Play track"
    )

    func run() throws {
        try! Player.action(.play)
    }
}
