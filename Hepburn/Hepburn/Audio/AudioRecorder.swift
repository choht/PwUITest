//
//  AudioRecorder.swift
//  Hepburn
//
//  Created by HyeonTae Cho on 2021/01/27.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation

class AudioRecorder: ObservableObject {
    
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    let audioFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("voice.wav")
    let audioRaw = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("voice.raw")
    var encodedFile = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("voice.txt")
    
    var audioRecorder: AVAudioRecorder!
    
    var isRecording = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    func existAudioFile() -> Bool {
        return FileManager.default.fileExists(atPath: audioFile.path)
    }
    
    func startRecording() {
        let recordSession = AVAudioSession.sharedInstance()
        
        do {
            try recordSession.setCategory(.playAndRecord, mode: .default)
            try recordSession.setActive(true)
        }
        catch {
            print("Failed to set up recording session.")
            return
        }
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ] as [String : Any]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFile, settings: settings)
            isRecording = audioRecorder.record()
        }
        catch {
            print("Could not start recording.")
        }
    }
    
    func stopRecording() {
        audioRecorder.stop()
        isRecording = false
    }
    
    func getRawData() -> Data? {
        do {
            let allData = try Data(contentsOf: audioFile)
            let dataBytes = Data([0x64, 0x61, 0x74, 0x61])
            var start = 0
            
            if let dataRange = allData.range(of: dataBytes) {
                start = dataRange.endIndex + 4
            }
            
            return allData.advanced(by: start)
        }
        catch {
            print("Could not open audio file.(\(error))")
        }
        return nil
    }
}
