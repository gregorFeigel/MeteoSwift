//
//  File.swift
//  
//
//  Created by Gregor Feigel on 12.12.23.
//

import Foundation
import SwiftNetCDF

// Generic Data API
public protocol DataAPI {
   subscript<T: NetcdfConvertible>(_ key: String) -> [T] { get throws }
}
