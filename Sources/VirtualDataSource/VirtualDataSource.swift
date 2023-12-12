//
// Logic layer for convenient interaction with multiple data sources

import Foundation
import NetCDF
import SwiftNetCDF
 
// MARK: - Generic Data API
public protocol DataAPI {
    subscript<T: NetcdfConvertible>(_ key: String) -> [T] { get throws }
}

extension NetCDFDocument: DataAPI { }

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
public class DriverInformation: DataSourceObject {
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

// MARK: Data Base Driver
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

// MARK: Virtual Data Source
@available(macOS 10.15.0, *)
public final class VirtualDataSource {
    
    init(driver: Driver = FileWrapperDriver()) {
        self.driver = driver
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

}

//@available(macOS 10.15.0, *)
//extension VirtualDataSource: DataAPI {
//    public func get() { }
//    
//    public func query() { }
//}

@available(macOS 10.15.0, *)
public protocol DataSource: DataAPI {
    
    func resolve() throws -> DataSourceInformation
}

// MARK: - NetCDF
@available(macOS 10.15.0, *)
extension NetCDFDocument: DataSource {
    public func resolve() throws -> DataSourceInformation {
        let span = try self.timeSpan
        return .init(dateSpan: Date(timeIntervalSince1970: span.start)...Date(timeIntervalSince1970: span.end),
                     variables: self.variables.map({ .init(key: $0) }),
                     source: self)
    }
}

// MARK: - CSV
//@available(macOS 10.15.0, *)
//public class CSVFile: DataSource {
//    let path: URL
//
//    init(path: URL) {
//        self.path = path
//    }
//    
//    public func resolve() throws -> DataSourceInformation {
//        .init(dateSpan: Date()...Date(), variables: [], source: self)
//    }
//}

// MARK: - Folder Content
public struct FileInformation {
    var name: String
    var creationDate: Date
    var lastModified: Date
    var size: Int
}

public struct FileExtension: Equatable, ExpressibleByStringLiteral {
    var alias: [String]
    
    public init(stringLiteral value: String) {
        alias = value.components(separatedBy: ",")
    }
}

public enum FileType: FileExtension {
    case netCDF = "nc"
    case csv = "csv"
}

typealias filterFunction = (FileInformation) -> Bool

//@available(macOS 10.15.0, *)
//public class FolderContent: DataSource {
//    let folder: URL
//    let filter: filterFunction?
//    let fileType: FileType
//    
//    init(folder: URL, fileType: FileType, filter: filterFunction?) {
//        self.folder = folder
//        self.fileType = fileType
//        self.filter = filter
//    }
//    
//    public func resolve() throws -> DataSourceInformation {
//        .init(dateSpan: Date()...Date(), variables: [], source: self)
//    }
//}

//@available(*, unavailable, message: "Needs further implementation")
//@available(macOS 10.15.0, *)
//public struct SourceAPI: DataSource {
//    public func resolve() async throws -> DataObject {
//        .init()
//    }
//}
//
//@available(*, unavailable, message: "Needs further implementation")
//@available(macOS 10.15.0, *)
//public struct RemoteSourceFile: DataSource {
//    public func resolve() async throws -> DataObject {
//        .init()
//    }
//}

public extension URL {
    
    static func +(lhs: URL, rhs: String) -> URL {
        lhs.appendingPathComponent(rhs)
    }
    
}

public extension Date {
    var isToday: Bool { return true }
}
