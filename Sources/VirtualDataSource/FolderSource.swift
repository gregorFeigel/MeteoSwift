//
//  File.swift
//  
//
//  Created by Gregor Feigel on 12.12.23.
//

import Foundation

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
