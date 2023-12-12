//
//  File.swift
//  
//
//  Created by Gregor Feigel on 12.12.23.
//

import Foundation

public extension URL {
    
    static func +(lhs: URL, rhs: String) -> URL {
        lhs.appendingPathComponent(rhs)
    }
    
}
