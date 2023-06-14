//===----------------------------------------------------------------------===//
//
// This source file is part of the MeteoSwift open source project
//
// Copyright (c) 2022 Gregor Feigel
// Licensed under MIT License
//
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//


import Foundation

@available(macOS 10.15.0, *)
extension Collection {
    
    func concurrentMap<T>(_ transform: @escaping (Element) async throws -> T) async rethrows -> [T] {
        return try await withThrowingTaskGroup(of: (Int, T).self, returning: [T].self, body: { group in
            
            for (i,n) in self.enumerated() {
                group.addTask {
                    return try await (i, transform(n))
                }
            }
            
            var result = [T?](repeatElement(nil, count: self.count))
            for try await n in group {
                result[n.0] = n.1
            }
            
            return result.compactMap({ $0 })
        })
    }
    
    func concurrentForEach(_ transform: @escaping (Element) async throws -> Void) async throws {
        await withThrowingTaskGroup(of: Void.self, body: { group in
            for n in self {
                group.addTask {
                    try await transform(n)
                }
            }
            
        })
    }
}
