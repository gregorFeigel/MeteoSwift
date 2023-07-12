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

public struct TemperaturUnit: MeteoUnit {
    
    public typealias unit_key = UnitKey
    
    public let unit: unit_key
    
    public static let degree_celcius:   TemperaturUnit  = .init(unit: .degree_celcius)
    public static let degree_farenheit: TemperaturUnit  = .init(unit: .degree_farenheit)
    public static let kelvin:           TemperaturUnit  = .init(unit: .kelvin)
    
    public enum UnitKey {
        case degree_celcius
        case degree_farenheit
        case kelvin
    }
    
    public var symbol: String {
        switch unit {
            case .degree_celcius:   return "°C"
            case .kelvin:           return "K"
            case .degree_farenheit: return "°F"
        }
    }
    
    public func makeConverter<T: FloatingNumber>(unit key: unit_key) -> ConverterFunction<T> {
        switch (unit, key) {
            case (.degree_celcius, .kelvin):
                return { (_ input: T) in
                    return input + 273.15
                }
            case (.degree_celcius, .degree_farenheit):
                return { (_ input: T) in
                    return (input * 1.8) + 32
                }
            case (.kelvin, .degree_celcius):
                return { (_ input: T) in
                    return input - 273.15
                }
            case (.kelvin, .degree_farenheit):
                return { (_ input: T) in
                    return 1.8 * (input - 273) + 32
                }
            case (.degree_farenheit, .degree_celcius):
                return { (_ input: T) in
                    return (input - 32) * 0.5556
                }
            case (.degree_farenheit, .kelvin):
                return { (_ input: T) in
                    return 273.5 + ((input - 32.0) * (5.0/9.0))
                }
                
                // cases that never should be called
            case (.degree_farenheit, .degree_farenheit):
                return { (_ input: T) in
                    return input
                }
                
            case (.kelvin, .kelvin):
                return { (_ input: T) in
                    return input
                }
                
            case (.degree_celcius, .degree_celcius):
                return { (_ input: T) in
                    return input
                }
        }
    }
    
}

public struct PressureUnit: MeteoUnit {
    public typealias unit_key = UnitKey
    
    public let unit: unit_key
    
    public static let pascal:           PressureUnit = .init(unit: .pascal)
    public static let kilopascal:       PressureUnit = .init(unit: .kilopascal)
    public static let hectopascal:      PressureUnit = .init(unit: .hectopascal)
    public static let megapascal:       PressureUnit = .init(unit: .megapascal)
    public static let millibar:         PressureUnit = .init(unit: .millibar)
    public static let bar:              PressureUnit = .init(unit: .bar)
    public static let kilo_bar:         PressureUnit = .init(unit: .kilo_bar)
    public static let psi:              PressureUnit = .init(unit: .psi)
    public static let inch_of_mercury:  PressureUnit = .init(unit: .inch_of_mercury)
    public static let atm:              PressureUnit = .init(unit: .atm)
    public static let torr:             PressureUnit = .init(unit: .torr)
    
    public enum UnitKey {
        case pascal
        case kilopascal
        case hectopascal
        case megapascal
        case millibar
        case bar
        case kilo_bar
        case psi
        case inch_of_mercury
        case atm
        case torr
    }
    
    public var symbol: String {
        switch unit {
            case .pascal:           return "pa"
            case .kilopascal:       return "kpa"
            case .hectopascal:      return "hpa"
            case .megapascal:       return "mpa"
            case .millibar:         return "mbar"
            case .bar:              return "bar"
            case .kilo_bar:         return "kbar"
            case .psi:              return "psi"
            case .inch_of_mercury:  return "in Hg"
            case .atm:              return "atm"
            case .torr:             return "torr"
        }
    }
    
    public func makeConverter<T: FloatingNumber>(unit key: unit_key) -> ConverterFunction<T> {
        switch (key, unit) {
            case (.millibar, .pascal):
                return { (_ input: T) in
                    return input * 100
                }
            case (.millibar, .kilopascal):
                return { (_ input: T) in
                    return input / 10
                }
            case (.millibar, .hectopascal):
                return { (_ input: T) in
                    return input // is the same
                }
            case (.millibar, .megapascal):
                return { (_ input: T) in
                    return input * 10_000
                }
            case (.millibar, .bar):
                return { (_ input: T) in
                    return input / 1_000
                }
            case (.millibar, .kilo_bar):
                return { (_ input: T) in
                    return input / 1_000_000
                }
            case (.millibar, .psi):
                return { (_ input: T) in
                    return input / 68.9475728
                }
            case (.millibar, .inch_of_mercury):
                return { (_ input: T) in
                    return input / 33.864
                }
            case (.millibar, .atm):
                return { (_ input: T) in
                    return input * 0.00098692326671
                }
            case (.millibar, .torr):
                return { (_ input: T) in
                    return input * 1.333
                }
            case (.millibar, .millibar):
                return { (_ input: T) in
                    return input
                }
            case (.torr, .bar):
                return { (_ input: T) in
                    return input / 750.1
                }
            case (.torr, .pascal):
                return { (_ input: T) in
                    return input * 133.3
                }
            case (.torr, .kilopascal):
                return { (_ input: T) in
                    return input / 7.501
                }
            case (.torr, .hectopascal):
                return { (_ input: T) in
                    return input * 1.333
                }
            case (.torr, .megapascal):
                return { (_ input: T) in
                    return input / 7501
                }
            case (.torr, .millibar):
                return { (_ input: T) in
                    return input * 1.333
                }
            case (.torr, .kilo_bar):
                return { (_ input: T) in
                    return (input * 1.333) / 1_000
                }
            case (.torr, .psi):
                return { (_ input: T) in
                    return input / 51.715
                }
            case (.torr, .inch_of_mercury):
                return { (_ input: T) in
                    return input / 25.4
                }
            case (.torr, .atm):
                return { (_ input: T) in
                    return input / 760
                }
            case (.torr, .torr):
                return { (_ input: T) in
                    return input
                }
            case (.atm, .pascal):
                return { (_ input: T) in
                    return input * 101300
                }
            case (.atm, .kilopascal):
                return { (_ input: T) in
                    return input / 101.3
                }
            case (.atm, .hectopascal):
                return { (_ input: T) in
                    return input / 1013
                }
            case (.atm, .megapascal):
                return { (_ input: T) in
                    return input / 9.869
                }
            case (.atm, .millibar):
                return { (_ input: T) in
                    return input / 1013
                }
            case (.atm, .bar):
                return { (_ input: T) in
                    return input * 1.013
                }
            case (.atm, .kilo_bar):
                return { (_ input: T) in
                    return (input * 1.013) * 1_000
                }
            case (.atm, .psi):
                return { (_ input: T) in
                    return input * 14.696
                }
            case (.atm, .inch_of_mercury):
                return { (_ input: T) in
                    return input * 29.921
                }
            case (.atm, .torr):
                return { (_ input: T) in
                    return input * 760
                }
            case (.atm, .atm):
                return { (_ input: T) in
                    return input
                }
            case (.inch_of_mercury, .pascal):
                return { (_ input: T) in
                    return input * 33864
                }
            case (.inch_of_mercury, .kilopascal):
                return { (_ input: T) in
                    return input * 3.3864
                }
            case (.inch_of_mercury, .hectopascal):
                return { (_ input: T) in
                    return input * 33.864
                }
            case (.inch_of_mercury, .megapascal):
                return { (_ input: T) in
                    return input / 295.3
                }
            case (.inch_of_mercury, .millibar):
                return { (_ input: T) in
                    return input * 33.864
                }
            case (.inch_of_mercury, .bar):
                return { (_ input: T) in
                    return input * 29.53
                }
            case (.inch_of_mercury, .kilo_bar):
                return { (_ input: T) in
                    return (input * 29.53) * 1_000
                }
            case (.inch_of_mercury, .psi):
                return { (_ input: T) in
                    return input / 2.036
                }
            case (.inch_of_mercury, .atm):
                return { (_ input: T) in
                    return input / 29.921
                }
            case (.inch_of_mercury, .torr):
                return { (_ input: T) in
                    return input *  25.4
                }
            case (.inch_of_mercury, .inch_of_mercury):
                return { (_ input: T) in
                    return input
                }
            case (.psi, .pascal):
                return { (_ input: T) in
                    return input * 6895
                }
            case (.psi, .kilopascal):
                return { (_ input: T) in
                    return input * 6.895
                }
            case (.psi, .hectopascal):
                return { (_ input: T) in
                    return input * 68.948
                }
            case (.psi, .megapascal):
                return { (_ input: T) in
                    return input / 145
                }
            case (.psi, .millibar):
                return { (_ input: T) in
                    return input * 68.95
                }
            case (.psi, .bar):
                return { (_ input: T) in
                    return input / 14.504
                }
            case (.psi, .kilo_bar):
                return { (_ input: T) in
                    return (input / 14.504) * 1_000
                }
            case (.psi, .inch_of_mercury):
                return { (_ input: T) in
                    return input * 2.036
                }
            case (.psi, .atm):
                return { (_ input: T) in
                    return input / 14.696
                }
            case (.psi, .torr):
                return { (_ input: T) in
                    return input * 51.715
                }
            case (.psi, .psi):
                return { (_ input: T) in
                    return input
                }
            case (.kilo_bar, .pascal):
                return { (_ input: T) in
                    return (input / 1_000) * 100_000
                }
            case (.kilo_bar, .kilopascal):
                return { (_ input: T) in
                    return(input / 1_000) * 100
                }
            case (.kilo_bar, .hectopascal):
                return { (_ input: T) in
                    return (input / 1_000) * 1_000
                }
            case (.kilo_bar, .megapascal):
                return { (_ input: T) in
                    return (input / 1_000) / 10
                }
            case (.kilo_bar, .millibar):
                return { (_ input: T) in
                    return (input / 1_000) / 1_000
                }
            case (.kilo_bar, .bar):
                return { (_ input: T) in
                    return input / 1_000
                }
            case (.kilo_bar, .psi):
                return { (_ input: T) in
                    return (input / 1_000) * 14.504
                }
            case (.kilo_bar, .inch_of_mercury):
                return { (_ input: T) in
                    return (input / 1_000) * 29.53
                }
            case (.kilo_bar, .atm):
                return { (_ input: T) in
                    return (input / 1_000) / 1.013
                }
            case (.kilo_bar, .torr):
                return { (_ input: T) in
                    return (input / 1_000) * 750.1
                }
            case (.kilo_bar, .kilo_bar):
                return { (_ input: T) in
                    return input
                }
            case (.bar, .pascal):
                return { (_ input: T) in
                    return input * 100_000
                }
            case (.bar, .kilopascal):
                return { (_ input: T) in
                    return input * 100
                }
            case (.bar, .hectopascal):
                return { (_ input: T) in
                    return input * 1_000
                }
            case (.bar, .megapascal):
                return { (_ input: T) in
                    return input / 10
                }
            case (.bar, .millibar):
                return { (_ input: T) in
                    return input / 1_000
                }
            case (.bar, .kilo_bar):
                return { (_ input: T) in
                    return input * 1_000
                }
            case (.bar, .psi):
                return { (_ input: T) in
                    return input * 14.504
                }
            case (.bar, .inch_of_mercury):
                return { (_ input: T) in
                    return input * 29.53
                }
            case (.bar, .atm):
                return { (_ input: T) in
                    return input / 1.013
                }
            case (.bar, .torr):
                return { (_ input: T) in
                    return input * 750.1
                }
            case (.bar, .bar):
                return { (_ input: T) in
                    return input
                }
                
            case (.megapascal, .pascal):
                return { (_ input: T) in
                    return input * 1_000_000
                }
            case (.megapascal, .kilopascal):
                return { (_ input: T) in
                    return input * 1_000
                }
            case (.megapascal, .hectopascal):
                return { (_ input: T) in
                    return input * 10_000
                }
            case (.megapascal, .megapascal):
                return { (_ input: T) in
                    return input
                }
            case (.megapascal, .millibar):
                return { (_ input: T) in
                    return input * 10000
                }
            case (.megapascal, .bar):
                return { (_ input: T) in
                    return input * 10
                }
            case (.megapascal, .kilo_bar):
                return { (_ input: T) in
                    return (input * 10) * 1_000
                }
            case (.megapascal, .psi):
                return { (_ input: T) in
                    return input * 145.038
                }
            case (.megapascal, .inch_of_mercury):
                return { (_ input: T) in
                    return input * 295.3
                }
            case (.megapascal, .atm):
                return { (_ input: T) in
                    return input * 9.869
                }
            case (.megapascal, .torr):
                return { (_ input: T) in
                    return input * 7501
                }
            case (.hectopascal, .pascal):
                return { (_ input: T) in
                    return input * 100
                }
            case (.hectopascal, .kilopascal):
                return { (_ input: T) in
                    return input / 10
                }
            case (.hectopascal, .hectopascal):
                return { (_ input: T) in
                    return input
                }
            case (.hectopascal, .megapascal):
                return { (_ input: T) in
                    return input / 10_000
                }
            case (.hectopascal, .millibar):
                return { (_ input: T) in
                    return input
                }
            case (.hectopascal, .bar):
                return { (_ input: T) in
                    return input / 1000
                }
            case (.hectopascal, .kilo_bar):
                return { (_ input: T) in
                    return (input / 1000) / 1_000
                }
            case (.hectopascal, .psi):
                return { (_ input: T) in
                    return input / 68.948
                }
            case (.hectopascal, .inch_of_mercury):
                return { (_ input: T) in
                    return input
                }
            case (.hectopascal, .atm):
                return { (_ input: T) in
                    return input / 33.864
                }
            case (.hectopascal, .torr):
                return { (_ input: T) in
                    return input / 1.333
                }
            case (.kilopascal, .pascal):
                return { (_ input: T) in
                    return input * 1000
                }
            case (.kilopascal, .kilopascal):
                return { (_ input: T) in
                    return input
                }
            case (.kilopascal, .hectopascal):
                return { (_ input: T) in
                    return input * 10
                }
            case (.kilopascal, .megapascal):
                return { (_ input: T) in
                    return input / 1000
                }
            case (.kilopascal, .millibar):
                return { (_ input: T) in
                    return input * 10
                }
            case (.kilopascal, .bar):
                return { (_ input: T) in
                    return input / 100
                }
            case (.kilopascal, .kilo_bar):
                return { (_ input: T) in
                    return (input / 100) * 1_000
                }
            case (.kilopascal, .psi):
                return { (_ input: T) in
                    return input / 6.895
                }
            case (.kilopascal, .inch_of_mercury):
                return { (_ input: T) in
                    return input / 3.386
                }
            case (.kilopascal, .atm):
                return { (_ input: T) in
                    return input /  101.3
                }
            case (.kilopascal, .torr):
                return { (_ input: T) in
                    return input * 7.501
                }
            case (.pascal, .pascal):
                return { (_ input: T) in
                    return input
                }
            case (.pascal, .kilopascal):
                return { (_ input: T) in
                    return input / 1000
                }
            case (.pascal, .hectopascal):
                return { (_ input: T) in
                    return input / 100
                }
            case (.pascal, .megapascal):
                return { (_ input: T) in
                    return input / 1_000_000
                }
            case (.pascal, .millibar):
                return { (_ input: T) in
                    return input / 100
                }
            case (.pascal, .bar):
                return { (_ input: T) in
                    return input / 100_000
                }
            case (.pascal, .kilo_bar):
                return { (_ input: T) in
                    return (input / 100_000) * 1_000
                }
            case (.pascal, .psi):
                return { (_ input: T) in
                    return input / 6895
                }
            case (.pascal, .inch_of_mercury):
                return { (_ input: T) in
                    return input / 3386
                }
            case (.pascal, .atm):
                return { (_ input: T) in
                    return input / 101300
                }
            case (.pascal, .torr):
                return { (_ input: T) in
                    return input / 133.3
                }
        }
    }
    
}

public struct EnergyUnit: MeteoUnit {
    public typealias unit_key = UnitKey
    
    public let unit: unit_key
    
    public static let watt_per_square_metre:      EnergyUnit = .init(unit: .watt_per_square_metre)
    public static let kilo_watt_per_square_metre: EnergyUnit = .init(unit: .kilo_watt_per_square_metre)
    public  static let mega_watt_per_square_metre: EnergyUnit = .init(unit: .mega_watt_per_square_metre)
    
    public enum UnitKey {
        case watt_per_square_metre
        case kilo_watt_per_square_metre
        case mega_watt_per_square_metre
    }
    
    public var symbol: String {
        switch unit {
            case .watt_per_square_metre:      return "W/m2"
            case .kilo_watt_per_square_metre: return "kW/m2"
            case .mega_watt_per_square_metre: return "mW/m2"
        }
    }
    
    public func makeConverter<T: FloatingNumber>(unit key: unit_key) -> ConverterFunction<T> {
        switch (key, unit) {
            case (.watt_per_square_metre, .kilo_watt_per_square_metre):
                return { (_ input: T) in
                    return input * 1_000
                }
            case (.watt_per_square_metre, .mega_watt_per_square_metre):
                return { (_ input: T) in
                    return input * 1_000_000
                }
            case (.kilo_watt_per_square_metre, .watt_per_square_metre):
                return { (_ input: T) in
                    return input / 1_000
                }
            case (.kilo_watt_per_square_metre, .mega_watt_per_square_metre):
                return { (_ input: T) in
                    return input * 1_000
                }
            case (.mega_watt_per_square_metre, .kilo_watt_per_square_metre):
                return { (_ input: T) in
                    return input * 1_000
                }
            case (.mega_watt_per_square_metre, .watt_per_square_metre):
                return { (_ input: T) in
                    return input / 1_000_000
                }
                
                // these cases shoulden't be called
            case (.mega_watt_per_square_metre, .mega_watt_per_square_metre):
                return { (_ input: T) in
                    return input
                }
            case (.kilo_watt_per_square_metre, .kilo_watt_per_square_metre):
                return { (_ input: T) in
                    return input
                }
                
            case (.watt_per_square_metre, .watt_per_square_metre):
                return { (_ input: T) in
                    return input
                }
        }
    }
}

public struct VolumeUnit: MeteoUnit {
    public typealias unit_key = UnitKey
    
    public let unit: unit_key
    
    public static var liter_per_square_meter:        VolumeUnit = .init(unit: .liter_per_square_meter)
    public static var liter_per_millimeter_per_hour: VolumeUnit = .init(unit: .millimeter_per_hour)
    
    public enum UnitKey {
        case liter_per_square_meter
        case millimeter_per_hour
    }
    
    public var symbol: String {
        switch unit {
            case .millimeter_per_hour:    return "mm/h"
            case .liter_per_square_meter: return "l/h"
        }
    }
    
    public func makeConverter<T: FloatingNumber>(unit key: unit_key) -> ConverterFunction<T> {
        switch (key, unit) {
            case (.liter_per_square_meter, .millimeter_per_hour):
                return { (_ input: T) in
                    return input
                }
            case (.millimeter_per_hour, .liter_per_square_meter):
                return { (_ input: T) in
                    return input
                }
            case (.millimeter_per_hour, .millimeter_per_hour):
                return { (_ input: T) in
                    return input
                }
            case (.liter_per_square_meter, .liter_per_square_meter):
                return { (_ input: T) in
                    return input
                }
        }
    }
}

public struct SpeedUnit: MeteoUnit {
    public typealias unit_key = UnitKey
    
    public let unit: unit_key
    
    public static var meter_per_second:     SpeedUnit = .init(unit: .meter_per_second)
    public static var meter_per_hour:       SpeedUnit = .init(unit: .meter_per_hour)
    public static var kilometer_per_hour:   SpeedUnit = .init(unit: .kilometer_per_hour)
    public static var miles_per_hour:       SpeedUnit = .init(unit: .miles_per_hour)
    public static var knot:                 SpeedUnit = .init(unit: .knot)
    
    public enum UnitKey {
        case meter_per_second
        case meter_per_hour
        case miles_per_hour
        case knot
        case kilometer_per_hour
    }
    
    public var symbol: String {
        switch unit {
            case .meter_per_second:    return "m/s"
            case .meter_per_hour:      return "m/h"
            case .miles_per_hour:      return "mph"
            case .knot:                return "kn"
            case .kilometer_per_hour:  return "km/h"
        }
    }
    
    public func makeConverter<T: FloatingNumber>(unit key: unit_key) -> ConverterFunction<T> {
        switch (key, unit) {
                // meter per second
            case(.meter_per_second, .meter_per_hour):
                return { (_ input: T) in
                    return input * 3600
                }
            case(.meter_per_second, .kilometer_per_hour):
                return { (_ input: T) in
                    return input * 3.6
                }
            case(.meter_per_second, .miles_per_hour):
                return { (_ input: T) in
                    return input * 2.237
                }
            case(.meter_per_second, .knot):
                return { (_ input: T) in
                    return input * 1.944
                }
            case(.meter_per_second, .meter_per_second):
                return { (_ input: T) in
                    return input
                }
                
                
                // kilometer_per_hour
            case (.kilometer_per_hour, .kilometer_per_hour):
                return { (_ input: T) in
                    return input
                }
            case (.kilometer_per_hour, .meter_per_second):
                return { (_ input: T) in
                    return input / 3.6
                }
            case (.kilometer_per_hour, .meter_per_hour):
                return { (_ input: T) in
                    return input * 1000
                }
            case (.kilometer_per_hour, .miles_per_hour):
                return { (_ input: T) in
                    return input * 1.609
                }
            case (.kilometer_per_hour, .knot):
                return { (_ input: T) in
                    return input / 1.852
                }
                
                // Knot
            case (.knot, .meter_per_second):
                return { (_ input: T) in
                    return input /  1.944
                }
            case (.knot, .meter_per_hour):
                return { (_ input: T) in
                    return input * 1852
                }
            case (.knot, .miles_per_hour):
                return { (_ input: T) in
                    return input * 1.151
                }
            case (.knot, .kilometer_per_hour):
                return { (_ input: T) in
                    return input * 1.852
                }
            case (.knot, .knot):
                return { (_ input: T) in
                    return input
                }
                
                // miles per hour
            case (.miles_per_hour, .meter_per_second):
                return { (_ input: T) in
                    return input / 2.237
                }
            case (.miles_per_hour, .meter_per_hour):
                return { (_ input: T) in
                    return input * 1609
                }
            case (.miles_per_hour, .knot):
                return { (_ input: T) in
                    return input / 1.151
                }
            case (.miles_per_hour, .kilometer_per_hour):
                return { (_ input: T) in
                    return input * 1.609
                }
            case (.miles_per_hour, .miles_per_hour):
                return { (_ input: T) in
                    return input
                }
                
                // meter per hour
            case (.meter_per_hour, .meter_per_second):
                return { (_ input: T) in
                    return input / 3600
                }
            case (.meter_per_hour, .miles_per_hour):
                return { (_ input: T) in
                    return input / 1609
                }
            case (.meter_per_hour, .knot):
                return { (_ input: T) in
                    return input / 1852
                }
            case (.meter_per_hour, .kilometer_per_hour):
                return { (_ input: T) in
                    return input / 1000
                }
            case (.meter_per_hour, .meter_per_hour):
                return { (_ input: T) in
                    return input
                }
        }
    }
}
