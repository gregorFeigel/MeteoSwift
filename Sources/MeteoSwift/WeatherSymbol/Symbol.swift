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

// NOTE: This code not is even close for production
public protocol Coordinate {
    var longitude: Double { get }
    var latitude:  Double { get }
}
//
//public struct WeatherDataSet {
//    
//    public init(solar_irradiance: Double = -1,
//                precipitation:    Double = -1,
//                wind:             Double = -1,
//                cloudiness:       Double = -1,
//                foggyness:        Double = -1,
//                visablility:      Double = -1,
//                snow_index:       Double = -1) {
//    self.solar_irradiance = solar_irradiance
//    self.precipitation = precipitation
//    self.wind = wind
//    self.cloudiness = cloudiness
//    self.foggyness = foggyness
//    self.visablility = visablility
//    self.snow_index = snow_index
//}
//    
//    var solar_irradiance: Double
//    var precipitation:    Double
//    var wind:             Double
//    var cloudiness:       Double
//    var foggyness:        Double
//    var visablility:      Double
//    var snow_index:       Double
//    
//    func mergeWith(_ data: WeatherDataSet) -> WeatherDataSet {
//        var new = WeatherDataSet()
//        
//        if data.solar_irradiance != self.solar_irradiance && data.solar_irradiance > -1 { new.solar_irradiance = data.solar_irradiance }
//        else { new.solar_irradiance = self.solar_irradiance }
//        
//        if data.precipitation != self.precipitation && data.precipitation > -1 { new.precipitation = data.precipitation }
//        else { new.precipitation = self.precipitation }
//        
//        if data.cloudiness != self.cloudiness && data.cloudiness > -1 { new.cloudiness = data.cloudiness }
//        else { new.cloudiness = self.cloudiness }
//        
//        if data.foggyness != self.foggyness && data.foggyness > -1 { new.foggyness = data.foggyness }
//        else { new.foggyness = self.foggyness }
//        
//        if data.visablility != self.visablility && data.visablility > -1 { new.visablility = data.visablility }
//        else { new.visablility = self.visablility }
//        
//        if data.snow_index != self.snow_index && data.snow_index > -1 { new.snow_index = data.snow_index }
//        else { new.snow_index = self.snow_index }
//        
//        return new
//    }
//}
//
//public struct WeatherIcon {
//    var icon: String
//    public var name: String
//}
//
//struct Weather {
//    
//    static var light_rain:     WeatherIcon = .init(icon: "􀇅", name: "cloud.drizzle.fill")
//    static var rain:           WeatherIcon = .init(icon: "􀇇", name: "cloud.rain.fill")
//    static var heavy_rain:     WeatherIcon = .init(icon: "􀇉", name: "cloud.heavyrain.fill")
//    static var foggy:          WeatherIcon = .init(icon: "􀇋", name: "cloud.fog.fill")
//    static var hail:           WeatherIcon = .init(icon: "􀇍", name: "cloud.hail.fill")
//    static var snow:           WeatherIcon = .init(icon: "􀇏", name: "cloud.snow.fill")
//    static var snow_rain:      WeatherIcon = .init(icon: "􀇑", name: "cloud.sleet.fill")
//    static var thounder:       WeatherIcon = .init(icon: "􀇓", name: "cloud.bolt.fill")
//    static var thounder_storm: WeatherIcon = .init(icon: "􀇟", name: "cloud.bolt.rain.fill")
//    static var sunny_rainy:    WeatherIcon = .init(icon: "􀇗", name: "cloud.sun.rain.fill")
//    static var rainy_night:    WeatherIcon = .init(icon: "􀇝", name: "cloud.moon.rain.fill")
//    static var cloudy:         WeatherIcon = .init(icon: "􀇃", name: "cloud.fill")
//    static var moon_cloud:     WeatherIcon = .init(icon: "􀇛", name: "cloud.moon.fill")
//    
//    static var sunrize:        WeatherIcon = .init(icon: "􀆲", name: "sunrise.fill")
//    static var sunset:         WeatherIcon = .init(icon: "􀆴", name: "sunset.fill")
//    static var sun_haze:       WeatherIcon = .init(icon: "􀆸", name: "sun.haze.fill")
//    static var sun_dust:       WeatherIcon = .init(icon: "􀆶", name: "sun.dust.fill")
//    static var clouds_sunny:   WeatherIcon = .init(icon: "􀇕", name: "cloud.sun.fill")
//    static var sunny:          WeatherIcon = .init(icon: "􀆬", name: "sun.min.fill")
//    static var bright_sun:     WeatherIcon = .init(icon: "􀆮", name: "sun.max.fill")
//    
//    static var wind:           WeatherIcon = .init(icon: "􀇤", name: "wind")
//    static var wind_snow:      WeatherIcon = .init(icon: "􀇦", name: "wind.snow")
//    static var storm:          WeatherIcon = .init(icon: "􀇧", name: "tornado")
//    static var hurricane:      WeatherIcon = .init(icon: "􀇩", name: "hurricane")
//    
//    static var moon:           WeatherIcon = .init(icon: "􀆺", name: "moon.fill")
//    static var moon_haze:      WeatherIcon = .init(icon: "􁑰", name: "moon.haze.fill")
//    static var moon_stars:     WeatherIcon = .init(icon: "􀇁", name: "moon.stars.fill")
//    
//    static var `default`:      WeatherIcon = .init(icon: "", name: "")
//    
////    .init(icon: "􀻟", name: "sun.and.horizon.fill")
////    static var light_rain: Symbol = .init(icon: "􀇙", name: "cloud.sun.bolt.fill")
////    static var light_rain: Symbol = .init(icon: "􀇡", name: "cloud.moon.bolt.fill")
//}
//
//@available(macOS 10.15, *)
//public struct WeatherSymbolMaker {
//    
//    public init(data: WeatherDataSet) {
//        self.data = data
//    }
//    
//    let data: WeatherDataSet
//    
//    public func weather_icon_for(coordinates: Coordinate, data stationData: WeatherDataSet) throws -> WeatherIcon {
//        let values: WeatherDataSet = data.mergeWith(stationData)
//        
//        // sunrise && sunset
//        let solar = Solar(coordinate: coordinates)
//        guard let sunrise_event: Bool = solar?.isSunriseEvent(within: 5) else { throw "error while calculating sunrise" }
//        guard let sunset_event:  Bool = solar?.isSunsetEvent(within: 5)  else { throw "error while calculating sunset"  }
//        guard let isNight:       Bool = solar?.isNighttime               else { throw "error while calculating daytime" }
//        
//        if sunrise_event { return Weather.sunrize }
//        if sunset_event  { return Weather.sunset }
//        
//        // Dominating weather condition
//        
//        // Case: Wind
//        // noticable wind (> 30km/h): wind
//        // very strong wind (> 80km/h): tornado
//        // hurricane (> 110km/h): hurricane
//        if values.wind > 30  { return Weather.wind  }
//        if values.wind > 80  { return Weather.storm }
//        if values.wind > 120 { return Weather.hurricane }
//        
//        if isNight {
//            if values.cloudiness    > 0.2 { return Weather.moon_cloud  }
//            if values.visablility   > 0.8 { return Weather.moon_stars  }
//            if values.precipitation > 0.5 { return Weather.rainy_night }
//            return Weather.moon
//        }
//        else {
//            if values.solar_irradiance > 250 { return Weather.bright_sun }
//            
//            /* Calculate weather */
//            
//            // Rain
//            // very little rainfall (<4l/h): cloud.sun.rain.fill
//            // little rainfall (~5l/h): cloud.rain.fill
//            // heavy  rainfall (>5l/h): cloud.heavyrain.fill
//            if values.precipitation > 0 && values.precipitation < 4.5 && values.solar_irradiance > 50 { return Weather.sunny_rainy }
//            else if values.precipitation > 0 && values.precipitation < 4.5 { return Weather.light_rain }
//            else if values.precipitation > 4.5 && values.precipitation < 7 { return Weather.rain }
//            else if values.precipitation > 7  { return Weather.heavy_rain }
//            
//            // fog
//            if values.foggyness > 0.8 { return Weather.foggy }
//            
//            if values.cloudiness > 0.5 && values.solar_irradiance > 50 { return Weather.clouds_sunny }
//            if values.cloudiness < 0.1 && values.solar_irradiance > 50 { return Weather.sunny        }
//        }
//
//        return Weather.default
//    }
//}
//
//extension String: Error {}
