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

public protocol FloatingNumber: ExpressibleByFloatLiteral, FloatingPoint, BinaryFloatingPoint {}
extension Double: FloatingNumber {}
extension Float:  FloatingNumber {}

public protocol Convertable {
    associatedtype num: FloatingNumber
    
    var key: String   { get set }
    var values: [num] { get set }
}

public protocol MeteoUnit {
    associatedtype unit_key: Hashable

    var unit: unit_key { get }
    var symbol: String { get }
    func makeConverter<T: FloatingNumber>(unit: unit_key) -> ConverterFunction<T>
}

public typealias ConverterFunction<T> = (T) -> T
typealias ConverterFunctionFloat = (Float)  -> Float

public enum ConverterError: Error {
    case invalidUnitPairs
    case missingSourceConvention
    case missingTargetConvention
    case conventionMissingUnitFor(ConventionVariables)
}

public final class MeterologicalConverter {
    
    public init(source_convention: (any Convention)? = nil, target_convention: (any Convention)? = nil) {
        self.base_convention = source_convention
        self.target_convention = target_convention
    }
    
    let base_convention:   (any Convention)?
    let target_convention: (any Convention)?
    
}

public extension MeterologicalConverter {
    
    func convert<T: FloatingNumber>(_ input: [String: [T]]) throws -> [String: [T]] {
        guard let base = base_convention   else { throw ConverterError.missingSourceConvention }
        guard let dest = target_convention else { throw ConverterError.missingTargetConvention }

        var new_dict: [String: [T]] = [:]
        for (key, value) in input {
            // key and values conversion
            // could be in async
            let unit_key = try base.get_variable_name(key)
            guard let src_unit:  any MeteoUnit  = base.unit_configuration[unit_key] else { throw ConverterError.conventionMissingUnitFor(unit_key) }
            guard let dest_unit: any MeteoUnit  = dest.unit_configuration[unit_key] else { throw ConverterError.conventionMissingUnitFor(unit_key) }
            let new_key: String = dest[unit_key]

            if src_unit.unit.hashValue == dest_unit.unit.hashValue { new_dict[new_key] = value; continue }

            let converter: ConverterFunction<T> = try make_converter(src_unit, to: dest_unit)
            let base_error_value:   T = base.get_error()
            let target_error_value: T = dest.get_error()
            new_dict[new_key] = value.map { $0 == base_error_value ? target_error_value : converter($0) }
        }
        return new_dict
    }
    
    func convert<T: Convertable>(_ input: [T]) throws -> [T] {
        guard let base = base_convention   else { throw ConverterError.missingSourceConvention }
        guard let dest = target_convention else { throw ConverterError.missingTargetConvention }

        return try input.map { n in
            let unit_key = try base.get_variable_name(n.key)
            guard let src_unit:  any MeteoUnit  = base.unit_configuration[unit_key] else { throw ConverterError.conventionMissingUnitFor(unit_key) }
            guard let dest_unit: any MeteoUnit = dest.unit_configuration[unit_key] else { throw ConverterError.conventionMissingUnitFor(unit_key) }
            let new_key: String = dest[unit_key]
            var copy: T = n
            copy.key = new_key

            if src_unit.unit.hashValue == dest_unit.unit.hashValue {
                copy.values = n.values
                return copy
            }
            
            let converter: ConverterFunction<T.num> = try make_converter(src_unit, to: dest_unit)
            let base_error_value:   T.num = base.get_error()
            let target_error_value: T.num = dest.get_error()
            copy.values = n.values.map { $0 == base_error_value ? target_error_value : converter($0) }
            return copy
        }
    }
    
    // async - concurrent
    @available(macOS 10.15.0, *)
    func concurrent_convert<T: Convertable>(_ input: [T]) async throws -> [T] {
        guard let base = base_convention   else { throw ConverterError.missingSourceConvention }
        guard let dest = target_convention else { throw ConverterError.missingTargetConvention }

        return try await input.concurrentMap { [self] n in
            let unit_key = try base.get_variable_name(n.key)
            guard let src_unit:  any MeteoUnit = base.unit_configuration[unit_key] else { throw ConverterError.conventionMissingUnitFor(unit_key) }
            guard let dest_unit: any MeteoUnit = dest.unit_configuration[unit_key] else { throw ConverterError.conventionMissingUnitFor(unit_key) }
            let new_key: String = dest[unit_key]
            var copy: T = n
            copy.key = new_key

            if src_unit.unit.hashValue == dest_unit.unit.hashValue {
                copy.values = n.values
                return copy
            }

            let converter: ConverterFunction<T.num> = try make_converter(src_unit, to: dest_unit)
            let base_error_value:   T.num = base.get_error()
            let target_error_value: T.num = dest.get_error()
            copy.values = n.values.map { $0 == base_error_value ? target_error_value : converter($0) }
            return copy
        }
    }

}

// MARK: Convserion routines
// simple array conversion
public extension MeterologicalConverter {
    
    // convert single array
    func convert<T: FloatingNumber, U: MeteoUnit>(_ input: [T], from src_unit: U, to dest_unit: U, error: T = .nan) throws -> [T] {
        let converter: ConverterFunction<T> = make_converter(src_unit, to: dest_unit)
        return input.map {  $0 == error ? $0 : converter($0) }
    }    
}

public extension MeterologicalConverter {
    
    func make_converter<T: FloatingNumber, P: MeteoUnit>(_ from: P, to: P) -> ConverterFunction<T> {
        let converter: ConverterFunction<T> = from.makeConverter(unit: to.unit)
        return converter
    }
    
    func make_converter<T: FloatingNumber, U: MeteoUnit, U2: MeteoUnit>(_ from: U, to: U2) throws -> ConverterFunction<T> {
        if U2.self == U.self {
            let converter: ConverterFunction<T> = from.makeConverter(unit: (to as! U).unit )
            return converter
        }
        else { throw ConverterError.invalidUnitPairs }
    }
    
}

