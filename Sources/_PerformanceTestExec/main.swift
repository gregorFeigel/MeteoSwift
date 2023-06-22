//
//  File.swift
//  
//
//  Created by Gregor Feigel on 13.06.23.
//

import Foundation
import _Performance

@available(macOS 10.15.0, *)
extension Collection {
    func __concurrentMap<T>(_ transform: @escaping (Element) async throws -> T?) async rethrows -> [T] {
        
        return try await withThrowingTaskGroup(of: (Int, T?).self, returning: [T].self, body: { group in
            
            for (i,n) in self.enumerated() {
                group.addTask {
                    let res = try await transform(n)
                    return (i, res)
                }
                
            }
            
            var result = [T?](repeatElement(nil, count: self.count))
            for try await n in group {
                result[n.0] = n.1
            }
            
            return result.compactMap({ $0 })
        })
    }
    
    
    func concurrentMap<T>(_ transform: @escaping (Element) async throws -> T?) async rethrows -> [T] {
        
        return try await withThrowingTaskGroup(of: (Int, T?).self) { group in
            
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
        }
        
         
    }
    
    
}


if #available(macOS 10.15.0, *) {
    
    //    struct OBJ: Identifiable {
    //        var id: String
    //    }
    //
    //    func load(id: any Identifiable) -> OBJ { .init(id: "new_obj") }
    //
    //    let mbuf: MemBuffer<OBJ> = MemBuffer(loader: load)
    //    _ = mbuf.get(.init(id: ""))
        let _ : [String] = await ["", "", "", ""].concurrentMap({ n in
            await endless()
            return ""
        })
    //
    
    func endless() async {
        while true {  }
    }
    
//    try await withThrowingTaskGroup(of: Void.self) { group in
//        // Create four tasks of the `endless` function
//        for _ in 1...4 {
//            group.addTask {
//                await endless()
//            }
//        }
//
//        for try await n in group {
//
//        }
//    }
    
    
    
    
}
