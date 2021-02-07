//
//  Speech.swift
//  Hepburn
//
//  Created by HyeonTae Cho on 2021/02/04.
//

import Foundation
import AVFoundation

class Speecher {
    
    func speak(talk: Talk?) {
        if talk == nil || talk!.code == nil || talk!.code! != 0 || talk!.reply == nil || talk!.reply!.count == 0 {
            print("Talk is nil")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers])
        }
        catch {
            print("Failed to set category AudioSession( \(error) )")
            return
        }
        
        let syn = AVSpeechSynthesizer()
        let u = AVSpeechUtterance(string: talk!.reply!)
        u.voice = AVSpeechSynthesisVoice(language: "en-US")
        u.rate = 0.4
        syn.speak(u)
    }
    
}
