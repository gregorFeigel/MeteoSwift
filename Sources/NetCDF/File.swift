//
//  File.swift
//  
//
//  Created by Gregor Feigel on 13.06.23.
//

import Foundation
import SwiftNetCDF
import _Performance

fileprivate protocol AnyInternalError: Error {}
extension String: AnyInternalError {}

public final class NetCDF_File {
    
    public init(url: URL) throws {
        self.url = url
        
        // check if file exsits
        if !FileManager.default.fileExists(atPath: url.path) {
            throw "File: \(url.path) does not exist."
        }
 
        guard let nc_file = try NetCDF.open(path: url.path, allowUpdate: false)
        else { throw "unable to open nc file." }
        self.file = nc_file
    }
    
    let url: URL
    let file: Group
    
    // list all available variable names
    public func list_variables() -> [String] {
        let variables = file.getVariables().compactMap({$0.name })
        return variables
    }
    
    // get the data content of a variable
    public func get<T: NetcdfConvertible>(key: String, as: T.Type) throws -> [T] {
        let variable = file.getVariable(name: key)
        guard let content: [T] = try variable?.asType(T.self)?.read()
        else { throw "unable to read variable: \(key)" }
        return content
    }

    public func get_all_readable_variables<T: NetcdfConvertible>(as: T.Type) throws -> [NCData<T>] {
        let variables = file.getVariables()
        let container: [NCData<T>?] = try variables.map { variable in
            if let content: [T] = try variable.asType(T.self)?.read() {
                return .init(key: variable.name,
                             values: content)
            }
            return nil
        }
        return container.compactMap({ $0 })
    }
    
    public func get_time<T: NetcdfConvertible>(_ key: String = "time", as: T.Type) throws -> NCData<T> {
        return try .init(key: key, values: get(key: key, as: T.self))
    }
    
    public func get_time<T: NetcdfConvertible>(_ key: String = "time", as: T.Type) throws -> [T] {
        return try get(key: key, as: T.self)
    }
}

public struct NCData<T: NetcdfConvertible> {
   public var key: String
   public var values: [T]
}
