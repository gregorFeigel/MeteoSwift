//
//  File.swift
//  
//
//  Created by Gregor Feigel on 12.12.23.
//

import Foundation
import NetCDF

extension NetCDFDocument: DataAPI { }

@available(macOS 10.15.0, *)
extension NetCDFDocument: DataSource {
    public func resolve() throws -> DataSourceInformation {
        let span = try self.timeSpan
        return .init(dateSpan: Date(timeIntervalSince1970: span.start)...Date(timeIntervalSince1970: span.end),
                     variables: self.variables.map({ .init(key: $0) }),
                     source: self)
    }
}
