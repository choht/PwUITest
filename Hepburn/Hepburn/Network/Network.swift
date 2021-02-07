//
//  Network.swift
//  Hepburn
//
//  Created by HyeonTae Cho on 2021/01/31.
//

import Foundation
import Combine

class Network: ObservableObject {
    
    let objectWillChange = PassthroughSubject<Network, Never>()
    
    let METHOD_TALK_VOICE = "/audrey/talk/voice"
    let METHOD_TALK_TEXT = "/audrey/talk/text"
    
    var isRequesting = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    var response = "Response" {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    func talk(url: String!, contents: Data?, responseHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        if isRequesting {
            debugPrint("Requesting...")
            return
        }
        
        let voice = contents?.base64EncodedString() ?? ""
        let u = URL(string: url + METHOD_TALK_VOICE)
        if u == nil {
            debugPrint("URL is invalid. (\(String(describing: url)))")
            return
        }
        
        let encodedVoice = voice.base64URLSafe()
        let req = post(url: u, body: jsonData(contents: encodedVoice, method: METHOD_TALK_VOICE), length: encodedVoice.count)
        let task = URLSession.shared.dataTask(with: req!) { (data, response, error) in
            DispatchQueue.main.async {
                self.setRequesting(false, method: self.METHOD_TALK_VOICE)
                
                responseHandler(data, response, error)
                
                debugPrint("Success")
            }
        }
        
        task.resume()
        
        setRequesting(true, method: METHOD_TALK_VOICE)
    }
    
    func text(url: String!, contents: String!, responseHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        if isRequesting {
            debugPrint("Requesting...")
            return
        }
        
        let u = URL(string: url + METHOD_TALK_TEXT)
        if u == nil {
            debugPrint("URL is invalid. (\(String(describing: url)))")
            return
        }
        
        let req = post(url: u!, body: jsonData(contents: contents, method: METHOD_TALK_TEXT), length: contents.count)
        let task = URLSession.shared.dataTask(with: req!) { (data, response, error) in
            DispatchQueue.main.async {
                self.setRequesting(false, method: self.METHOD_TALK_TEXT)
                
                responseHandler(data, response, error)
                
                debugPrint("Success")
            }
        }
        
        task.resume()
        
        setRequesting(true, method: METHOD_TALK_VOICE)
    }
    
    private func jsonData(contents: String!, method: String!) -> Data? {
        switch method {
        case METHOD_TALK_VOICE:
            return jsonVoice(encodedString: contents)
        case METHOD_TALK_TEXT:
            return jsonText(contents: contents)
        default:
            return nil
        }
    }
    
    private func jsonText(contents: String!) -> Data? {
        do {
            let v: [String : String?] = [
                "text": contents
            ]
            
            return try JSONSerialization.data(withJSONObject: v, options: .withoutEscapingSlashes)
        }
        catch {
            debugPrint("Failed to get json (\(error))")
        }
        return nil
    }
    
    private func jsonVoice(encodedString: String!) -> Data? {
        do {
            let v: [String : String?] = [
                "raw": encodedString
            ]
            
            return try JSONSerialization.data(withJSONObject: v, options: .withoutEscapingSlashes)
        }
        catch {
            debugPrint("Failed to get json (\(error))")
        }
        
        return nil
    }
    
    private func post(url: URL!, body: Data?, length: Int) -> URLRequest! {
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Accept")
        req.addValue("application/json", forHTTPHeaderField: "Content-type")
        req.setValue(String(length), forHTTPHeaderField: "Content-Length")
        req.httpBody = body
        return req
    }
    
    private func setRequesting(_ isRequesting: Bool, method: String?) {
        self.isRequesting = isRequesting
        debugPrint("'\(method ?? "None")' - requesting : \(isRequesting)")
    }
}

protocol NetworkDelegate {
    
    func response()
    
}

extension String {
    
    func base64URLSafe() -> String {
        return self.replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "+", with: "-")
    }
    
}
