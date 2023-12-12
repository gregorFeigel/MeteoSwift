// Logic stack for convenient interaction with multiple data sources

import Foundation
import NetCDF
import SwiftNetCDF
import Convention

// MARK: - Driver
@available(macOS 10.15.0, *)
public protocol DataSourceObject: Identifiable {
    var objectID: String { get set }
    var dateSpan: ClosedRange<Date> { get set }
    var variables: [Variable] { get set }
    var sourceInformation: [DataSourceInformation] { get set }
}

@available(macOS 10.15.0, *)
public protocol Driver {
    func register<T: DataSourceObject>(_ obj: T) throws
    
    func getObj(key: String) throws -> DataAPI
    
    func dump()
}

@available(macOS 10.15.0, *)
extension DriverInformation: DataAPI {
    // find the correct files
    public subscript<T>(key: String) -> [T] where T : SwiftNetCDF.NetcdfConvertible {
        get throws {
            var container: [T] = []
            for n in sourceInformation where n.variables.contains(.init(key: key)) {
                let content: [T] = try n.source[key]
                container += content
            }
            return container
        }
    }
    
}

@available(macOS 10.15.0, *)
public class FileWrapperDriver: Driver {
    var routerTable: [DriverInformation] = []
    
    public func getObj(key: String) throws -> DataAPI {
        routerTable.first(where: { $0.objectID == key })!
    }
    
    public func register<T: DataSourceObject>(_ obj: T) throws {
        routerTable.append(obj as! DriverInformation)
    }
    
    public func dump() {
        for n in routerTable {
            print(n.objectID + ":", n.dateSpan)
            for variable in n.variables {
                print("\t", variable.key)
            }
        }
    }
}




// MARK: - Info Container
public protocol ExpectedVariableSet {}

@available(macOS 10.15.0, *)
public protocol DataSource: DataAPI {
    func resolve() throws -> DataSourceInformation
}

public struct Variable: Hashable {
    var key: String
}

@available(macOS 10.15.0, *)
public class DataSourceInformation: Identifiable {
    init(id: UUID = UUID(), dateSpan: ClosedRange<Date>, variables: [Variable], source: DataSource) {
        self.id = id
        self.dateSpan = dateSpan
        self.variables = variables
        self.source = source
    }
    
    public var id: UUID = UUID()
    var dateSpan: ClosedRange<Date>
    var variables: [Variable]
    var source: DataSource
}

@available(macOS 10.15.0, *)
public class DriverInformation: DataSourceObject, ExpectedVariableSet {
    init(id: UUID = UUID(), objectID: String, dateSpan: ClosedRange<Date>, variables: [Variable], sourceInformation: [DataSourceInformation]) {
        self.id = id
        self.objectID = objectID
        self.dateSpan = dateSpan
        self.variables = variables
        self.sourceInformation = sourceInformation
    }

    public var id: UUID = UUID()
    public var objectID: String
    public var dateSpan: ClosedRange<Date>
    public var variables: [Variable]
    public var sourceInformation: [DataSourceInformation]
}



// MARK: - Virtual Data Source
@available(macOS 10.15.0, *)
public final class VirtualDataSource<T: Convention> {
    var t: T.Type
    
    init(driver: Driver = FileWrapperDriver(), convention: T.Type) {
        self.driver = driver
        self.t = convention
    }
    
    let driver: Driver
    
    public func register(id: String, source: [DataSource]) throws {
        var metaData: DriverInformation? = nil
        
        for n in source {
            let sourceMetaData = try n.resolve()
            if let root = metaData {
                // check total domain
                if sourceMetaData.dateSpan.lowerBound < root.dateSpan.lowerBound {
                    root.dateSpan = sourceMetaData.dateSpan.lowerBound...root.dateSpan.upperBound
                }
                if sourceMetaData.dateSpan.upperBound > root.dateSpan.upperBound {
                    root.dateSpan = root.dateSpan.lowerBound...sourceMetaData.dateSpan.upperBound
                }
                
                // check variable list
                for variable in sourceMetaData.variables {
                    if !root.variables.contains(variable) { root.variables.append(variable) }
                }
                
                // register driver time + var dimension
                root.sourceInformation.append(sourceMetaData)
            }
            else {
                metaData = .init(objectID: id,
                                 dateSpan: sourceMetaData.dateSpan,
                                 variables: sourceMetaData.variables,
                                 sourceInformation: [sourceMetaData])
            }
        }
        
        // ensure chronological order
        guard let root = metaData else { throw "unable to register \(id)" }
        
        let sortedDriverInformation = root.sourceInformation.sorted { (info1, info2) -> Bool in
            return info1.dateSpan.lowerBound < info2.dateSpan.lowerBound
        }
        
        root.sourceInformation = sortedDriverInformation
        
        try driver.register(root)
    }
    
    public func register(id: String, source: DataSource...) throws {
        try register(id: id, source: source)
    }
    
    public func resolve() async throws { }
    
    public func dump() {
        driver.dump()
    }
    
    public subscript(_ key: String) -> DataAPI {
        get throws {
            try driver.getObj(key: key)
        }
    }
    
    func excpect(`var`: String, unit: any MeteoUnit, alias: String...) { }
    
}
