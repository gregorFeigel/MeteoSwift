//
//  File.swift
//  
//
//  Created by Gregor Feigel on 13.06.23.
//

import Foundation
import _Performance
if #available(macOS 10.15.0, *) {
    
    struct OBJ: Identifiable {
        var id: String
    }
    
    func load(id: any Identifiable) -> OBJ { .init(id: "new_obj") }
    
    let mbuf: MemBuffer<OBJ> = MemBuffer(loader: load)
    _ = mbuf.get(.init(id: ""))

}
