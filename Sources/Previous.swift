import AppKit
import ArgumentParser
import Foundation

struct Previous: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Play previous track"
    )

    func run() throws {
        try! Player.action(.previous)
    }
}
