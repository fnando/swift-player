import AppKit
import ArgumentParser
import Foundation

struct Stop: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Stop track"
    )

    func run() throws {
        try! Player.action(.stop)
    }
}
