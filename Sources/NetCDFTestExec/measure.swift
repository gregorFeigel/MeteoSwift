//
//  File.swift
//  
//
//  Created by Gregor Feigel on 13.06.23.
//

import Foundation
import NetCDF
import _Metrics

func measure_nc() throws {
    if #available(macOS 10.15.0, *) {
        
        let nc = try NetCDF_File(url: URL(fileURLWithPath: "/Users/gregorfeigel/test.nc"))
        var air_temp: [Float]   = []
        var variables: [String] = []
        var all_variables: [NCData<Float>] = []
        
        measure("variables of .nc") {
            variables = nc.list_variables()
            print(variables.count)
        }
        
        try measure("load all variables of .nc") {
            all_variables = try nc.get_all_readable_variables(as: Float.self)
        }
        
        try measure("get time .nc") {
            let _ : NCData<Double> = try nc.get_time(as: Double.self)
        }
        
        try measure("load .nc") {
            air_temp = try nc.get(key: "AirTemp", as: Float.self)
        }
        
        print(air_temp.count)
        
    }
}
