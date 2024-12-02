import AppKit
import ArgumentParser
import CryptoKit
import Foundation

struct TrackData: Codable {
    let title: String?
    let artist: String?
    let album: String?
    let trackNumber: Int?
    let duration: Double?
    let playingTimestamp: Date?
    let isPlaying: Bool
    let artwork: String?
    let artworkWidth: Int?
    let artworkHeight: Int?
}

struct Track: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Get info about the current playing track"
    )

    @Flag(help: "Save cover to the specified path if available")
    var artwork = false

    func run() throws {
        try! Player.nowPlayingInfo { info in
            var savedArtwork = false
            let mime_type = info["kMRMediaRemoteNowPlayingInfoArtworkMIMEType"] as? String ?? "image/jpeg"
            let data = info["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data
            let mimes = [
                "image/jpeg": "jpg",
                "image/png": "png",
            ]
            let extname = mimes[mime_type] ?? "jpg"
            var outputPath = URL(string: "/tmp")!

            if data != nil && artwork {
                let hexdigest = Insecure.MD5.hash(data: data!).map { String(format: "%02x", $0) }.joined()
                outputPath = URL(fileURLWithPath: outputPath.appending(path: "\(hexdigest).\(extname)").path)

                if !FileManager.default.fileExists(atPath: outputPath.path) {
                    try! data!.write(to: outputPath)
                }

                savedArtwork = true
            }

            do {
                let track = TrackData(
                    title: info["kMRMediaRemoteNowPlayingInfoTitle"] as? String,
                    artist: info["kMRMediaRemoteNowPlayingInfoArtist"] as? String,
                    album: info["kMRMediaRemoteNowPlayingInfoAlbum"] as? String,
                    trackNumber: info["kMRMediaRemoteNowPlayingInfoTrackNumber"] as? Int,
                    duration: info["kMRMediaRemoteNowPlayingInfoDuration"] as? Double,
                    playingTimestamp: info["kMRMediaRemoteNowPlayingInfoTimestamp"] as? Date,
                    isPlaying: info["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Int ?? 0 == 1,
                    artwork: savedArtwork ? outputPath.path : nil,
                    artworkWidth: info["kMRMediaRemoteNowPlayingInfoArtworkDataWidth"] as? Int,
                    artworkHeight: info["kMRMediaRemoteNowPlayingInfoArtworkDataHeight"] as? Int
                )

                let encoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
                encoder.dateEncodingStrategy = .iso8601
                let data = try encoder.encode(track)

                if let json = String(data: data, encoding: .utf8) {
                    print(json)
                }
            } catch {
                print("Error converting dictionary to JSON: \(error)")
            }
        }
    }
}
