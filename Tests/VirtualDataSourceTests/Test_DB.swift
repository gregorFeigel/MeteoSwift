//
//  File.swift
//  
//
//  Created by Gregor Feigel on 12.12.23.
//

import Foundation

import XCTest
@testable import VirtualDataSource
@testable import NetCDF
@testable import Convention

final class VirtualDataSource_Test: XCTestCase {
    
    // create 4 month of data and spread it over 4 nc files
    func mock_nc_files() throws -> [URL] {
        var files: [URL] = []
        var count: Int = 0
        
        for i in 1...4 {
            try withUnsafeTmpFile { n in
                FileManager.default.createFile(atPath: n.path, contents: nil)
                
                let dates = allMinutesOf(month: i, year: 2023)
                
                let nc = try NetCDFDocument(url: n, fileMode: .forceWrite)
                try nc.setDimension(name: "time", legth: dates.count)
                try nc.setDimension(name: "longitude", legth: 1)
                try nc.setDimension(name: "latitude",  legth: 1)

                nc["latitude", to: "latitude"]   = [40.0]
                nc["longitude", to: "longitude"] = [7.0]
                nc["time", to: "time"] = dates.map({ $0.timeIntervalSince1970 })
                
                nc["AirTemp"] = Array(repeating: 10.0 * Double(i), count: dates.count)
            
                files.append(n)
                
                count += dates.count
            }
        }
        
        print(count)
        return files
    }
    
    func test_db() async throws {
        // create 4 month of data and spread it over 4 nc files
        let files: [URL] = try mock_nc_files()
        defer { try? removeFiles(files) }
                
        let data_source = VirtualDataSource(convention: CFConvention.self)
        data_source.excpect(var: "air_temperature", unit: TemperaturUnit.degree_celcius, alias: "AirTemp")
        data_source.excpect(var: "pet", unit: TemperaturUnit.degree_celcius)
        
        try data_source.register(id: "FRHERD", source: try NetCDFDocument(url: .documentsDirectory + "WSN_T1_YEAR/NetCDF/Stations/FRHERD_year.nc"))
        try data_source.register(id: "FRGUNT", source: try NetCDFDocument(url: .documentsDirectory + "WSN_T1_YEAR/NetCDF/Stations/FRGUNT_year.nc"))
        try data_source.register(id: "FRTEST", source: try files.map({ try NetCDFDocument(url: $0) }))
        
        // read all data
        let ta: [Double] = try data_source["FRTEST"][CFConvention.air_temperature.rawValue]
        
        XCTAssertTrue(ta.count == 172740)
    }
}

//        let ta: Double = data_source["FRGUNT"].query(.air_temperature)
//        data_source.register(id: "FRHERD", source: try NetCDFDocument(url: .documentsDirectory + "WSN_Freiburg/FRHERD.nc"), CSVFile(path: .documentsDirectory + "WSN_Freiburg/FRHERD.csv"))
//
//        data_source.register(id: "FRGUNT", source: CSVFile(path: .documentsDirectory + "WSN_Freiburg/FRGUNT.nc"))
//
//        data_source.register(id: "FRPDAS", source: FolderContent(folder: .documentsDirectory + "WSN_Freiburg/FRPDAS",
//                                                                 fileType: .netCDF,
//                                                                 filter: { $0.creationDate.isToday }))

func withTmpFile(_ f: (URL) throws -> ()) rethrows {
    let tmpFile: URL = FileManager.default.temporaryDirectory.appendingPathComponent("com.test-" + UUID().uuidString)
    defer { try? FileManager.default.removeItem(atPath: tmpFile.path) }
    try f(tmpFile)
}

func withUnsafeTmpFile(_ f: (URL) throws -> ()) rethrows {
    let tmpFile: URL = FileManager.default.temporaryDirectory.appendingPathComponent("com.test-" + UUID().uuidString)
    try f(tmpFile)
}

func removeFiles(_ f: [URL]) throws {
    for n in f { try FileManager.default.removeItem(atPath: n.path) }
}

func allMinutesOf(month: Int, year: Int) -> [Date] {
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current // You can set the desired time zone

    guard let januaryStartDate = calendar.date(from: DateComponents(year: year, month: month, day: 1, hour: 0, minute: 0, second: 0)),
          let februaryStartDate = calendar.date(from: DateComponents(year: year, month: month + 1, day: 1, hour: 0, minute: 0, second: 0)),
          let minutesInJanuary = calendar.dateComponents([.minute], from: januaryStartDate, to: februaryStartDate).minute else {
        return []
    }

    var allMinutes: [Date] = []

    for minute in 0..<minutesInJanuary {
        if let date = calendar.date(byAdding: .minute, value: minute, to: januaryStartDate) {
            allMinutes.append(date)
        }
    }

    return allMinutes
}
