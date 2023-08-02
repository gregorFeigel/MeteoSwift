//
//  File.swift
//  
//
//  Created by Gregor Feigel on 13.06.23.
//

import Foundation
import NetCDF
import _Metrics
import MeteoSwift


// try measure_nc()
public extension String {
    
    @Sendable func toDate(format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
    
}

func grid() {
    
    let start = "05.01.2023 01:00".toDate(format: "dd-MM-yyyy hh:mm")!
    let end   = "05.01.2024 02:00".toDate(format: "dd-MM-yyyy hh:mm")!
    
    //var time: [Double] = Array.init(repeating: 0, count: 120)
    //time = time.map { _ in .random(in: start.timeIntervalSince1970..<end.timeIntervalSince1970) }
    let time_step = 30
    let numIntervals = Int((end.timeIntervalSince1970 - start.timeIntervalSince1970) / Double(time_step))
    var griddedTime = [Double](repeating: 0, count: numIntervals)
    for i in 0..<numIntervals {
        griddedTime[i] = start.timeIntervalSince1970 + Double(i) * Double(time_step)
    }
    
    var values: [Float] = Array.init(repeating: -9999, count: numIntervals)
    values = values.map { _ in .random(in: 0..<55) }
    
    let x = gridMeasurements(timestamp: griddedTime,
                             values: values,
                             from: "05.01.2023 00:00".toDate(format: "dd-MM-yyyy hh:mm")!, // "09.07.2022".toDate(format: "dd-MM-yyyy")!
                             to: "05.01.2024 03:00".toDate(format: "dd-MM-yyyy hh:mm")!,
                             intervalSizeInSeconds: 300) // 5 min
    
    print(x.griddedData.count,
          x.griddedTime.count)
    print()
    
    //for n in 0..<x.griddedData.count {
    //    print(x.griddedData[n])
    //}
    
}

func withTmpFile(_ f: (URL) throws -> ()) rethrows {
    let tmpFile: URL = FileManager.default.temporaryDirectory.appendingPathComponent("com.test-" + UUID().uuidString)
    defer { try? FileManager.default.removeItem(atPath: tmpFile.path) }
    try f(tmpFile)
}


try withTmpFile { file in
        
    let nc = try NetCDFDocument(url: file, fileMode: .write)
    
    try nc.setDimension(name: "longitude", legth: 1)
    try nc.setDimension(name: "latitude",  legth: 1)
    try nc.setDimension(name: "time",      legth: 2)

    // write values to some dimensions
    nc["longitude", to: "longitude"] = [17.0]
    nc["latitude",  to: "latitude"]  = [47.0]
    nc["time",      to: "time"]      = [0.0,  2.0]
    
    // write values to all dimensions
    nc["air_temp"]  = [0.0,  2.0]
    
    // read value from variable
    let values: [Double] = try nc["air_temp"]
    print("air_temp", values)
    
}
