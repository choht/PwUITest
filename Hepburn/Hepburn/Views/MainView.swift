//
//  MainView.swift
//  Hepburn
//
//  Created by HyeonTae Cho on 2021/01/24.
//

import SwiftUI

struct MainView: View {
    
    private let speecher = Speecher()
    
    @EnvironmentObject var pref: Preferences
    
    @ObservedObject var audioRecorder = AudioRecorder()
    @ObservedObject var audioPlayer = AudioPlayer()
    
    @ObservedObject var network = Network()
    
    @State private var reqText = ""
        
    @State private var reply: Talk? {
        didSet {
            if reply != nil {
                self.speech(talk: reply)
            }
        }
    }
    @State private var echo: Talk?
    
    var body: some View {
        
        // Server address, port
        VStack {
                        
            TextField("Input Server Address", text: self.$pref.serverAddress)
                .padding()
            
            TextField("Input Server Port", text: self.$pref.serverPort)
                .keyboardType(.numberPad)
                .padding()
        
//            HStack {
//                // Record
//                Button(action: {
//                    if self.audioRecorder.isRecording {
//                        self.audioRecorder.stopRecording()
//                    }
//                    else {
//                        self.audioRecorder.startRecording()
//                    }
//                }) {
//                    Text(audioRecorder.isRecording ? "Stop Recording" : "Start Recording")
//                        .disabled(self.audioPlayer.isPlaying || self.network.isRequesting)
//                        .padding()
//                }
//
//                Spacer()
//
//                // Play
//                Button(action: {
//                    if !self.audioPlayer.isPlaying {
//                        self.audioPlayer.startPlayback(audio: self.audioRecorder.audioFile)
//                    }
//                }) {
//                    Text("Play")
//                        .disabled(self.audioRecorder.isRecording || self.audioPlayer.isPlaying || self.network.isRequesting)
//                        .padding()
//                }
//
//                Spacer()
//
//                // Send
//                Button(action: {
//                    self.sendTalk()
//                }) {
//                    Text("Send")
//                        .disabled(self.audioRecorder.isRecording || self.audioPlayer.isPlaying || !self.audioRecorder.existAudioFile() || self.network.isRequesting)
//                        .padding()
//                }
//            } // HStack
            
//            HStack {
//                Text(self.reply?.reply ?? "Response")
//                    .font(.body)
//                    .padding()
//
//                Spacer()
//
//                Button(action: {
//                    self.speech(talk: reply)
//                }) {
//                    Text("TTS")
//                        .padding()
//                }
//            }
//
//            Spacer()
//
//            TextField("Input Text", text: self.$reqText)
//                .padding()
//
//            HStack {
//                // Send
//                Button(action: {
//                    self.sendText()
//                }) {
//                    Text("Send")
//                        .disabled(self.audioRecorder.isRecording || self.audioPlayer.isPlaying || !self.audioRecorder.existAudioFile() || self.network.isRequesting)
//                        .padding()
//                }
//            }
//
//            HStack {
//                Text(self.echo?.reply ?? "Response")
//                    .font(.body)
//                    .padding()
//
//                Spacer()
//
//                Button(action: {
//                    self.speech(talk: echo)
//                }) {
//                    Text("TTS")
//                        .padding()
//                }
//            }

            // Response and TTS
            HStack {
                Text(self.reply?.reply ?? "Response")
                    .font(.body)
                    .padding()

                Spacer()

                Button(action: {
                    self.speech(talk: reply)
                }) {
                    Text("TTS")
                        .padding()
                }
            }
            
            Spacer()
            
            Button(action: {
                if self.audioRecorder.isRecording {
                    self.audioRecorder.stopRecording()
                    self.sendTalk()
                }
                else {
                    self.audioRecorder.startRecording()
                }
            }) {
                Text(audioRecorder.isRecording ? "Stop Recording" : "Start Recording")
                    .disabled(self.audioPlayer.isPlaying || self.network.isRequesting)
                    .padding()
            }
        }
    }
    
    private func sendTalk() {
        network.talk(url: self.pref.getServerUrl(), contents: self.audioRecorder.getRawData(), responseHandler: { (data, response, error) in
            if let e = error {
                reply = Talk()
                reply!.code = 400
                reply!.reply = e.localizedDescription
                return
            }
            
            do {
                reply = try JSONDecoder().decode(Talk.self, from: data!)
            }
            catch {
                print("Failed to parse JSON. (\(error))")
            }
        })
    }
    
    private func sendText() {
        network.text(url: self.pref.getServerUrl(), contents: self.reqText, responseHandler: { (data, response, error) in
            if let e = error {
                echo = Talk()
                echo!.code = 400
                echo!.reply = e.localizedDescription
                return
            }
            
            do {
                echo = try JSONDecoder().decode(Talk.self, from: data!)
            }
            catch {
                print("Failed to parse JSON. (\(error))")
            }
        })
    }
    
    private func speech(talk: Talk?) {
        speecher.speak(talk: talk)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(Preferences())
    }
}
