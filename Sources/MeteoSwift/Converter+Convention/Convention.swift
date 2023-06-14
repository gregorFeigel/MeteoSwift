//===----------------------------------------------------------------------===//
//
// This source file is part of the MeteoSwift open source project
//
// Copyright (c) 2022 Gregor Feigel
// Licensed under MIT License
//
//
// SPDX-License-Identifier: MIT
//
//===----------------------------------------------------------------------===//

import Foundation

public protocol Convention {
    associatedtype num: FloatingNumber

    var name: String { get }
    var unit_configuration: [ConventionVariables: any MeteoUnit] { get }
    var error_value: num { get }
    
    func get_variable_name(_ : String) throws -> ConventionVariables
    subscript(_ v: ConventionVariables) -> String { get }
}

extension Convention {
    
    func get_error<T: FloatingNumber>() -> T {
        return T(error_value)
    }
}

public enum ConventionError: Error {
    case unknownVariableName
}

public enum ConventionVariables {
    case air_temperature
    case relative_humidity
    case solar_radiation
    case air_pressure
    case water_vapor_pressure
    case wind_speed
    case wind_from_direction
    case precipitation_amount
    case black_globe_temperature
    case pet
    case dew_point
}

@available(macOS 10.15.0, *)
public struct CF_Convention: Convention {
    public init() {}
    
    public var error_value: some FloatingNumber = -9999.0
    
    public let name: String = "CF-1.6"
    
    public let unit_configuration: [ConventionVariables: any MeteoUnit] = [
        // variable name         |  unit
        .air_temperature:          TemperaturUnit.kelvin,
        .air_pressure:             PressureUnit.pascal,
        .black_globe_temperature:  TemperaturUnit.kelvin,
        .dew_point:                TemperaturUnit.kelvin,
        .pet:                      TemperaturUnit.kelvin,
        .water_vapor_pressure:     PressureUnit.pascal,
//        .precipitation_amount:    .mm_per_hour,
//        .solar_radiation:         .watt_per_m2,
//        .relative_humidity:       .percent,
//        .wind_speed:              .meter_per_second
    ]
    
    public subscript(_ v: ConventionVariables) -> String {
        switch v {
            case .air_temperature:          return "air_temperature"
            case .relative_humidity:        return "relative_humidity"
            case .solar_radiation:          return "solar_radiation"
            case .air_pressure:             return "air_pressure"
            case .water_vapor_pressure:     return "water_vapor_pressure"
            case .wind_speed:               return "wind_speed"
            case .wind_from_direction:      return "wind_from_direction"
            case .precipitation_amount:     return "precipitation_amount"
            case .black_globe_temperature:  return "black_globe_temperature"
            case .pet:                      return "pet"
            case .dew_point:                return "dew_point"
        }
    }
    
    public func get_variable_name(_ input: String) throws -> ConventionVariables {
        switch input {
            case "air_temperature":          return .air_temperature
            case "relative_humidity":        return .relative_humidity
            case "solar_radiation":          return .solar_radiation
            case "air_pressure":             return .air_pressure
            case "water_vapor_pressure":     return .water_vapor_pressure
            case "wind_speed":               return .wind_speed
            case "wind_from_direction":      return .wind_from_direction
            case "precipitation_amount":     return .precipitation_amount
            case "black_globe_temperature":  return .black_globe_temperature
            case "pet":                      return .pet
            case "dew_point":                return .dew_point
                
            default: throw ConventionError.unknownVariableName
        }
    }
}

//
// 20.03 - 21.03
//
