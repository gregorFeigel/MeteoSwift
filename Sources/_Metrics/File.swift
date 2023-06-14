//
//  File.swift
//  
//
//  Created by Gregor Feigel on 13.06.23.
//

import Foundation

@available(macOS 10.15.0, *)
public func measure(_ id: String = "", _ f: () async throws -> ()) async rethrows {
    let start = DispatchTime.now()
    
    try await f()
    
    let end = DispatchTime.now()
    let duration = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
    print("\(id):", "\(duration) seconds")
}

public func measure(_ id: String = "", _ f: () throws -> ())  rethrows {
    let start = DispatchTime.now()
    
    try f()
    
    let end = DispatchTime.now()
    let duration = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
    print("\(id):", "\(duration) seconds")
}
