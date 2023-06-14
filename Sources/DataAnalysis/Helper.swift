//
//  File.swift
//  
//
//  Created by Gregor Feigel on 13.06.23.
//

import Foundation
import SwiftUI


struct PreviewObject: Codable {
    var description: String
    var img: Data?
}

@available(macOS 10.15.0, *)
final class QuickViewClient {
    
    init(clientID: String,
         hostname: String = "localhost",
         port: Int = 3434) {
        self.clientID = clientID
        self.port = port
        self.hostname = hostname
    }
    
    let clientID: String
    let port: Int
    let hostname: String
    
    func updateQuickView(_ previewObject: PreviewObject) async throws {
        guard let url = URL(string: "http://\(hostname):\(port)/img/\(clientID)") else {
            throw NSError(domain: "Invalid URL", code: -1, userInfo: nil)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(previewObject)
        } catch {
            throw error
        }
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Response status code: \(httpResponse.statusCode)")
        }
    }
}

extension CGImage {
  
    func pngData() -> Data? {
    let cfdata: CFMutableData = CFDataCreateMutable(nil, 0)
    if let destination = CGImageDestinationCreateWithData(cfdata, kUTTypePNG as CFString, 1, nil) {
      CGImageDestinationAddImage(destination, self, nil)
      if CGImageDestinationFinalize(destination) {
        return cfdata as Data
      }
    }
    
    return nil
  }
}
