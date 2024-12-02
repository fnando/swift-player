import AppKit
import ArgumentParser
import Foundation

enum ActionName: Int {
    case play = 0
    case pause = 1
    case toggle_play_pause = 2
    case stop = 12
    case next = 4
    case previous = 5
    case shuffle = 114
}

struct Player: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Control the media player",
        subcommands: [
            Track.self,
            Play.self,
            Pause.self,
            Stop.self,
            Next.self,
            Previous.self,
            PlayPause.self,
        ]
    )

    static func nowPlayingInfo(_ action: @escaping ([String: Any]) -> Void) throws {
        let bundle = try! mediaRemote()

        let command = unsafeBitCast(
            CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString),
            to: (@convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void).self
        )

        command(DispatchQueue.global(qos: .default)) { info in
            action(info)
            DispatchQueue.main.async {
                NSApplication.shared.terminate(nil)
            }
        }
    }

    static func action(_ action: ActionName) throws {
        let bundle = try! mediaRemote()

        let command = unsafeBitCast(
            CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteSendCommand" as CFString),
            to: (@convention(c) (Int, Any?) -> Bool).self
        )

        _ = command(action.rawValue, nil)

        DispatchQueue.main.async {
            NSApplication.shared.terminate(nil)
        }
    }

    static func mediaRemote() throws -> CFBundle {
        guard let frameworkURL = URL(string: "/System/Library/PrivateFrameworks/MediaRemote.framework"),
              let bundle = CFBundleCreate(kCFAllocatorDefault, frameworkURL as CFURL)
        else {
            throw NSError(
                domain: "com.fnando.player",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Unable to retrieve MediaRemote"]
            )
        }

        return bundle
    }
}

Player.main()
NSApplication.shared.run()
