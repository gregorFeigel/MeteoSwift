//
//  File.swift
//  
//
//  Created by Gregor Feigel on 13.06.23.
//

import Foundation
import SwiftUI
import NetCDF

if #available(macOS 13.0, *) {
    
    let nc = try NetCDF_File(url: URL(fileURLWithPath: "/Users/gregorfeigel/test.nc"))
    let air_temp = try nc.get(key: "AirTemp", as: Float.self)
    
    let view = SwiftUIView(air_temp: air_temp)
    
    // PREVIEW STUFF
    let quickView = QuickViewClient(clientID: "DataAnalysis")
    guard let img: CGImage = await ImageRenderer(content: view).cgImage
    else { throw "error while rendering image"  }
    try await quickView.updateQuickView(.init(description: "Test Rendering of UIView from terminal", img: img.pngData()))
    
//
//    FileManager.default.createFile(atPath: "/Users/gregorfeigel/Documents/shevbslhrbvlsrebveslvblseresrvbweirvwievciu.png",
//                                   contents: img.pngData(),
//                                   attributes: nil)
//
}
