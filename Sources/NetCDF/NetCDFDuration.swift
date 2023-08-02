//
//  File 2.swift
//  
//
//  Created by Gregor Feigel on 02.08.23.
//

import Foundation

@frozen
public struct NetCDFDuration: Sendable {
    
    public init(_ duration: Int64) {
        self.seconds = duration
    }
    
    public init(milliSeconds: Int) {
        self.seconds = Int64(milliSeconds / 1000)
    }
    
    public init(seconds: Int) {
        self.seconds = Int64(seconds)
    }
    
    public init(minutes: Int) {
        self.seconds = Int64(minutes * 60)
    }
    
    public init(hours: Int)   {
        self.seconds = Int64(hours * 3600)
    }
    
    public init(years: Int)   {
        self.seconds = Int64(years * 31_556_952)
    }
    
    public var seconds: Int64
    
    public static func milliSeconds(_ duration: Int64) -> NetCDFDuration {
        return .init(Int64(duration / 1000))
    }
    
    public static func seconds(_ duration: Int64) -> NetCDFDuration {
        return .init(duration)
    }
    
    public static func minutes(_ duration: Int64) -> NetCDFDuration {
        return .init(Int64(duration * 60))
    }
    
    public static func hours(_ duration: Int64) -> NetCDFDuration {
        return .init(Int64(duration * 3600))
    }
    
    public static func years(_ duration: Int64) -> NetCDFDuration {
        return .init(Int64(duration * 31_556_952))
    }

}




