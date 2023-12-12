//
//  File.swift
//  
//
//  Created by Gregor Feigel on 12.12.23.
//

import Foundation
import Convention

public protocol Convention {
    associatedtype num: FloatingNumber

    var unit: any MeteoUnit { get }
    var error: num { get }
    var alias: String? { get }
}

extension Convention {
    var alias: String? { nil }
}

@available(macOS 10.15.0, *)
enum CFConvention: String, Convention {
    case air_temperature   = "AirTemperature"
    case humidity          = "Humidity"
    case barometicPressure = "BarometicPressure"
    
    var error: some FloatingNumber { -9999.0 }
    
    var unit: any MeteoUnit {
        switch self {
            case .air_temperature:   return TemperaturUnit.degree_celcius
            case .humidity:          return TemperaturUnit.degree_celcius
            case .barometicPressure: return PressureUnit.hectopascal
        }
    }
}
