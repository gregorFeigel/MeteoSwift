//
//  File.swift
//  
//
//  Created by Gregor Feigel on 13.06.23.
//

import Foundation

@available(macOS 10.15.0, *)
public extension Collection {
    
    func concurrentMap<T>(_ transform: @escaping (Element) throws -> T?) async rethrows -> [T] {
        return try await withThrowingTaskGroup(of: (Int, T?).self, returning: [T].self, body: { group in
            
            for (i,n) in self.enumerated() {
                group.addTask {
                    return try (i, transform(n))
                }
            }
            
            var result = [T?](repeatElement(nil, count: self.count))
            for try await n in group {
                result[n.0] = n.1
            }
            
            return result.compactMap({ $0 })
        })
    }
    
    func async_map<T>(_ transform: (Element) async throws -> T) async rethrows -> [T] {
        var container: [T] = []
        for n in self {
            try await container.append(transform(n))
        }
        return container
    }
    
    func concurrentForEach(_ transform: @escaping (Element) throws -> Void) async rethrows {
        await withThrowingTaskGroup(of: Void.self, body: { group in
            for n in self {
                group.addTask {
                    try transform(n)
                }
            }
        })
    }
}
