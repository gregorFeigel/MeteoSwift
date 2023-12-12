import XCTest
@testable import MeteoSwift
@testable import Convention

final class MeteoSwift_Coverter_Test: XCTestCase {

    let converter = MeterologicalConverter(source_convention: CF_Convention(),
                                           target_convention: MyConvention())
    // convert array
    func test_array_float() throws {

        var data: [Float] = [0, -1, -2, -3, -4, -5]

        // print the source and result
        printing_closure("Source") { print(data) }

        data = try converter.convert(data, from: TemperaturUnit.degree_celcius, to: TemperaturUnit.kelvin)

        printing_closure("Converted") { print(data) }
    }

    func test_array_double() throws {

        var data: [Double] = [0, -1, -2, -3, -4, -5]

        // print the source and result
        printing_closure("Source") { print(data) }

        data = try converter.convert(data, from: TemperaturUnit.degree_celcius, to: TemperaturUnit.kelvin)

        printing_closure("Converted") { print(data) }
    }

    // convert: tulple
    func test_tulple_float() throws {

        var data: [String: [Float]] = [ "air_temperature":      [0, -9999.0, 1, 2 ,3, 4 ,5],
                                        "water_vapor_pressure": [0, -1, -2, -3, -4, -5]   ]

        // print the source and result
        printing_closure("Source") { print(data) }

        data = try converter.convert(data)

        printing_closure("Converted") { print(data) }
    }

    func test_tulple_double() throws {

        var data: [String: [Double]] = [ "air_temperature":      [0, -9999.0, 1, 2 ,3, 4 ,5],
                                         "water_vapor_pressure": [0, -1, -2, -3, -4, -5]   ]

        // print the source and result
        printing_closure("Source") { print(data) }

        data = try converter.convert(data)

        printing_closure("Converted") { print(data) }
    }

    // convert: struct
    func test_struct_float() throws {

        var data: [KeyValueFloat] = [
            .init(key: "air_temperature", values: [0, -9999.0, 1, 2 ,3, 4 ,5]),
            .init(key: "water_vapor_pressure", values: [0, -1, -2, -3, -4, -5])
        ]

        // print the source and result
        printing_closure("Source") { print(data) }

        data = try converter.convert(data)

        printing_closure("Converted") { print(data) }

    }

    func test_struct_double() throws {

        var data: [KeyValueDouble] = [
            .init(key: "air_temperature", values: [0, -9999.0, 1, 2 ,3, 4 ,5]),
            .init(key: "water_vapor_pressure", values: [0, -1, -2, -3, -4, -5])
        ]

        // print the source and result
        printing_closure("Source") { print(data) }

        data = try converter.convert(data)

        printing_closure("Converted") { print(data) }

    }

    // cleaner printing
    func printing_closure(_ p: String, _ v: () -> ()) {
        print("\n" + p)
        v()
        print()
    }
}

final class MeteoSwift_Concurrent_Coverter_Test: XCTestCase {

    let converter = MeterologicalConverter(source_convention: CF_Convention(),
                                           target_convention: MyConvention())

    // convert: struct
    func test_struct_float() async throws {

        var data: [KeyValueFloat] = [
            .init(key: "air_temperature", values: Array(repeating: Float.random(in: 0...270), count: 1_000_000)),
            .init(key: "water_vapor_pressure", values: Array(repeating: Float.random(in: 0...270), count: 1_000_000))
        ]

        var avg_1: Float = 0
        var avg_2: Float = 0

        // print the source and result
        printing_closure("Source") {
            avg_1 = data[0].values.reduce(0, +) / Float(data[0].values.count)
            print(avg_1)
        }

        data = try await converter.concurrent_convert(data)

        printing_closure("Converted") {
            avg_2 = data[0].values.reduce(0, +) / Float(data[0].values.count)
            print(avg_2)
        }

        XCTAssertEqual(avg_1, (avg_2 + 273.15), accuracy: 10)
    }

    func test_struct_double() async throws {

        var data: [KeyValueDouble] = [
            .init(key: "air_temperature", values: Array(repeating: Double.random(in: 0...270), count: 1_000_000)),
            .init(key: "water_vapor_pressure", values: Array(repeating: Double.random(in: 0...270), count: 1_000_000))
        ]

        var avg_1: Double = 0
        var avg_2: Double = 0

        // print the source and result
        printing_closure("Source") {
            avg_1 = data[0].values.reduce(0, +) / Double(data[0].values.count)
            print(avg_1)
        }

        data = try await converter.concurrent_convert(data)

        printing_closure("Converted") {
            avg_2 = data[0].values.reduce(0, +) / Double(data[0].values.count)
            print(avg_2)
        }

        XCTAssertEqual(avg_1, (avg_2 + 273.15), accuracy: 0.1)

    }

    func printing_closure(_ p: String, _ v: () -> ()) {
        print("\n" + p)
        v()
        print()
    }
}

@available(macOS 10.15.0, *)
struct MyConvention: Convention {

    let error_value: some FloatingNumber = Double.nan

    public let name: String = "MyConvention"

    public let unit_configuration: [ConventionVariables: any MeteoUnit] = [
        // variable name         |  unit
        .air_temperature:           TemperaturUnit.degree_celcius,
        .air_pressure:              PressureUnit.hectopascal,
        .black_globe_temperature:   TemperaturUnit.degree_celcius,
        .dew_point:                 TemperaturUnit.degree_celcius,
        .pet:                       TemperaturUnit.degree_celcius,
        .water_vapor_pressure:      PressureUnit.hectopascal,
//        .precipitation_amount:    .mm_per_hour,
//        .solar_radiation:         .watt_per_m2,
//        .relative_humidity:       .percent,
//        .wind_speed:              .meter_per_second
    ]

    public subscript(_ v: ConventionVariables) -> String {
        switch v {
            case .air_temperature:          return "temperatur"
            case .relative_humidity:        return "relative_humidity"
            case .solar_radiation:          return "solar_radiation"
            case .air_pressure:             return "air_pressure"
            case .water_vapor_pressure:     return "dampfdruck"
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
            case "temperatur":               return .air_temperature
            case "relative_humidity":        return .relative_humidity
            case "solar_radiation":          return .solar_radiation
            case "air_pressure":             return .air_pressure
            case "dampfdruck":               return .water_vapor_pressure
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

struct KeyValueDouble: Convertable {
    var key: String
    var values: [Double]
}

struct KeyValueFloat: Convertable {
    var key: String
    var values: [Float]
}
