//
//  AudioService.swift
//  Myres
//
//  Created by Luis Genesius on 04/05/21.
//

import AVFoundation

public class AudioService {
    public static let instance = AudioService()
    
    private var audioPlayer: AVAudioPlayer?
    
    public func playBackgroundMusic(sound: String, type: String) {
        if let path = Bundle.main.path(forResource: sound, ofType: type) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.volume = 0.4
                audioPlayer?.play()
                audioPlayer?.numberOfLoops = -1
            }
            catch {
                print(error.localizedDescription)
            }
        }
    }
    
    public func pauseMusic() {
        audioPlayer?.pause()
    }
    
    public func resumeMusic() {
        audioPlayer?.play()
    }
}
