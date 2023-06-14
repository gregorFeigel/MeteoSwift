//
//  File.swift
//  
//
//  Created by Gregor Feigel on 13.06.23.
//

import Foundation

@available(macOS 10.15, *)
public class MemBuffer<T: Identifiable> {
    
    public init(buffer: [T] = [], loader: @escaping (any Identifiable) -> T) {
        self.buffer = buffer
        self.loader = loader
    }
 
    var buffer: [T] = []
    var loader: (any Identifiable) -> T
    
    public func get(_ obj: T) -> T {
        if let element = buffer.first(where: { $0.id == obj.id }) {
            return element
        }
        let new_obj = loader(obj)
        buffer.append(new_obj)
        return new_obj
    }
    
}
