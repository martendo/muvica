import UIKit
import AVFoundation

class ShakerAudioPlayer: NSObject, AVAudioPlayerDelegate {
	var assets: [String : NSDataAsset] = [:]
	var players: [String : AVAudioPlayer] = [:]
	var dupPlayers: [AVAudioPlayer] = []

	func playSound(_ name: String) {
		if let player = self.players[name] {
			if !player.isPlaying {
				// Existing audio player is not in use -> use this one
				player.play()
			} else {
				// Duplicate this audio player to play the sound on top
				do {
					// Data asset is known to exist in the dictionary because it has already been used
					let dupPlayer = try AVAudioPlayer(data: self.assets[name]!.data)
					dupPlayer.delegate = self
					self.dupPlayers.append(dupPlayer)
					dupPlayer.play()
				} catch let error as NSError {
					print(error.localizedDescription)
				}
			}
		} else {
			do {
				if let asset = NSDataAsset(name: name) {
					self.assets[name] = asset
					let player = try AVAudioPlayer(data: asset.data)
					self.players[name] = player
					player.play()
				}
			} catch let error as NSError {
				print(error.localizedDescription)
			}
		}
	}

	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		// Remove duplicate audio players once finished playing
		if let index = self.dupPlayers.firstIndex(of: player) {
			self.dupPlayers.remove(at: index)
		}
	}
}
