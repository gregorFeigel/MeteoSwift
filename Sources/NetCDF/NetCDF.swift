//
//  File 2.swift
//  
//
//  Created by Gregor Feigel on 02.08.23.
//

import Foundation
import SwiftNetCDF
import _Performance

fileprivate protocol AnyInternalError: Error {}
extension String: AnyInternalError {}

public enum FileMode {
    case read
    case write
    case forceWrite
}

public final class NetCDFDocument {
    
    public init(url: URL, fileMode: FileMode = .read) throws {
        self.url = url
        self.fileMode = fileMode
        
        if fileMode == .read {
            // check if file exsits
            if !FileManager.default.fileExists(atPath: url.path) {
                throw "File: \(url.path) does not exist."
            }
            
            guard let nc_file = try NetCDF.open(path: url.path, allowUpdate: false)
            else { throw "unable to open nc file." }
            self.file = nc_file
        }
        else {
            self.file = try NetCDF.create(path: url.path, overwriteExisting: fileMode == .forceWrite ? true : false)
        }
    }
    
    let url: URL
    let file: Group
    let fileMode: FileMode
    
    public var timeKey: String = "time"
    
    public subscript<T: NetcdfConvertible>(_ key: String) -> [T] {
        get throws {
            guard let variable = file.getVariable(name: key)
            else { throw "unable to read variable: \(key)" }
            
            guard let content: [T] = try variable.asType(T.self)?.read()
            else {
                let variableType = variable.type.asExternalDataType()
                let str = variableType != nil ? "\(variableType!)" : "#ERROR:unableToConvertNetCDFType"
                throw "variable '\(key)' cannot conform to \(T.self) as it is of type \(str)"
            }
           
            return content
        }
    }

    public subscript<T: NetcdfConvertible>(_ key: String,  to to: String...) -> [T]? {
        get { return nil }
        set(newValue) {
            do {
                if variables.contains(key) {
                    guard let variable = file.getVariable(name: key)
                    else { throw "mysteriously lost variable '\(key)'" }
                    
                    guard var writableVariable = variable.asType(T.self)
                    else {
                        let variableType = variable.type.asExternalDataType()
                        let str = variableType != nil ? "\(variableType!)" : "#ERROR:unableToConvertNetCDFType"
                        throw "variable '\(key)' cannot conform to \(T.self) as it is of type \(str)"
                    }
                    
                    if let _newValue = newValue {
                        try writableVariable.write(_newValue)
                    }
                    else { throw "values to be set must not be nil" }
                }
                // Create variable and write values to it
                else {
                    var dimensions = file.getDimensions()
                    if dimensions.isEmpty { throw "no dimensions set" }
                    
                    if !to.isEmpty {
                        dimensions = dimensions.filter({ to.contains($0.name) })
                        if dimensions.count < 1 { throw "Cannot find any dimension within '\(to)'" }
                    }
                    
                    var variable = try file.createVariable(name: key, type: T.self, dimensions: dimensions)
                    if let _newValue = newValue {
                        try variable.write(_newValue)
                        variables.append(key)
                    }
                    else { throw "new value must not be nil" }
                }
            }
            catch { print("[ ERROR ]", key, ":", error) }
         }
    }
    
    public lazy var variables: [String] = {
        return file.getVariables().compactMap({ $0.name })
    }()
    
    @Sendable public func get_all_readable_variables<T: NetcdfConvertible>() throws -> [NCData<T>] {
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
    
    // time operators
    @Sendable public func time<T: NetcdfConvertible>(_ key: String = "time") throws -> NCData<T> {
        return try .init(key: key, values: self[key])
    }
    
    @Sendable public func time<T: NetcdfConvertible>(_ key: String = "time") throws -> [T] {
        return try self[key]
    }
    
    private var timeBuffer: [Double]? = nil
    public var time: [Double] {
        get throws {
            if let buff = timeBuffer { return buff }
            else {
                let _time: [Double] = try self[timeKey]
                timeBuffer = _time
                return _time
            }
        }
    }
    
    private var timeSpanBuffer: (start: Double, end: Double)? = nil
    public var timeSpan: (start: Double, end: Double) {
        get throws {
            if let buff = timeSpanBuffer { return buff }
            let _time = try time
            guard let firstTimeStamp = _time.first else { throw "unable to access first timestamp" }
            guard let lastTimeStamp  = _time.last  else { throw "unable to access last timestamp" }
            timeSpanBuffer = (start: firstTimeStamp, end: lastTimeStamp)
            return (start: firstTimeStamp, end: lastTimeStamp)
        }
    }
    
    @Sendable public func read<T: NetcdfConvertible>(varibale key: String, from: Date, to: Date) throws -> [T] {
        return []
    }
    
    @Sendable public func read(varibale key: String, from: Date, to: Date, stepSize: NetCDFDuration) throws -> [Float] {
        let griddedvalues = try regrid(timestamp: time,
                                       values: self[key],
                                       from: from,
                                       to: to,
                                       intervalSizeInSeconds: Double(stepSize.seconds))
        
        return griddedvalues.griddedData
    }
    
    @Sendable public func timeAxis(from: Date, to: Date, interval: NetCDFDuration) -> [Double] {
        let seconds = Double(interval.seconds)
        let numIntervals = Int((to.timeIntervalSince1970 - from.timeIntervalSince1970) / seconds)
        
        var griddedTime = [Double](repeating: 0, count: numIntervals)
        
        for i in 0..<numIntervals {
            griddedTime[i] = from.timeIntervalSince1970 + Double(i) * seconds
        }
        
        return griddedTime
    }
    
    @Sendable public func timeAxis(from: Date, to: Date, interval: NetCDFDuration) -> [Float] {
        let seconds = Double(interval.seconds)
        let numIntervals = Int((to.timeIntervalSince1970 - from.timeIntervalSince1970) / seconds)
        
        var griddedTime = [Float](repeating: 0, count: numIntervals)
        
        for i in 0..<numIntervals {
            griddedTime[i] = Float(from.timeIntervalSince1970 + Double(i) * seconds)
        }
        
        return griddedTime
    }
    
    // Dimensions
    @discardableResult
    @Sendable public func setDimension(name: String, legth: Int) throws -> SwiftNetCDF.Dimension  {
        return try file.createDimension(name: name, length: legth)
    }
    
}

public extension String {
    
    func date(_ format: String = "dd-MM-yyyy HH:mm", timeZone: TimeZone = TimeZone(abbreviation: "UTC")!) throws -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timeZone
        guard let date = dateFormatter.date(from: self) else {
            throw "invalid Date Format"
        }
        return date
    }
    
    func date(_ format: String = "dd-MM-yyyy HH:mm", timeZone: TimeZone = TimeZone(abbreviation: "UTC")!) throws -> Double {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timeZone
        
        guard let date = dateFormatter.date(from: self) else {
            throw "invalid Date Format"
        }
        
        return date.timeIntervalSince1970
    }
}

