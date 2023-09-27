//
//  File.swift
//  
//
//  Created by Gregor Feigel on 10.07.23.
//

import Foundation
import NetCDF


@discardableResult
@Sendable public func gridMeasurements(timestamp: [Double], values: [Float], from: Date, to: Date, intervalSizeInSeconds: Double) throws -> (griddedTime: [Double], griddedData: [Float])  {
 
    if values.count > timestamp.count { throw "Invalid array dimensions. There must be no more data than time stamps." }
    
    // Calculate the number of intervals needed to cover the entire range of time data
    let numIntervals = Int((to.timeIntervalSince1970 - from.timeIntervalSince1970) / intervalSizeInSeconds) //+ 1
    
    
    // Create an array to store the gridded time points and initialize it with the appropriate number of elements
    var griddedTime = [Double](repeating: 0, count: numIntervals)
    
    // Iterate over the gridded time array and calculate each time point based on the interval size and the minimum timestamp
    for i in 0..<numIntervals {
        griddedTime[i] = from.timeIntervalSince1970 + Double(i) * intervalSizeInSeconds
    }
    
    // Create a dictionary to store the gridded data values, with time points as keys and an array of values as values
    let from_date = from.timeIntervalSince1970
    
    var griddedData = [[Float]?](repeating: nil, count: numIntervals)
 
    for i in 0..<timestamp.count {
        let index = Int((timestamp[i] - from_date) / intervalSizeInSeconds)
        if griddedData[index] == nil {
            griddedData[index] = [values[i]]
        }
        else { griddedData[index]! += [values[i]] }
    }
    
    let return_value: [Float] = griddedData.map { n in
        if let x = n {
            let c = x.filter({ $0 != -9999.0 })
            if c.isEmpty { return -9999  }
            return c.reduce(0, +)
        }
        else { return -9999 }
    }
    
    return (griddedTime, return_value)
}



 
