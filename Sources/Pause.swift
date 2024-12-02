import AppKit
import ArgumentParser
import Foundation

struct Pause: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Pause track"
    )

    func run() throws {
        try! Player.action(.pause)
    }
}
