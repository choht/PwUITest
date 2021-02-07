//
//  AudioPlayer.swift
//  Hepburn
//
//  Created by HyeonTae Cho on 2021/01/27.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    let objectWillChange = PassthroughSubject<AudioPlayer, Never>()
    
    var audioPlayer: AVAudioPlayer!
    
    var isPlaying = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            isPlaying = false
        }
    }

    func startPlayback(audio: URL) {
        if !FileManager().fileExists(atPath: audio.path) {
            print("Audio file ( \(audio.path) ) is not exist.")
            return
        }
        
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSession.Category.playback)
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            try audioSession.setActive(true)
        }
        catch {
            print("Playing over the device's speakers failed.( \(error) )")
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audio)
            audioPlayer.delegate = self
            isPlaying = audioPlayer.play()
        }
        catch {
            print("Playback failed")
        }
    }
    
    func stopPlayback() {
        audioPlayer.stop()
        isPlaying = false
    }
}
