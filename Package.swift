// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MeteoSwift",
    products: [
        .library(name: "MeteoSwift" ,   targets: ["MeteoSwift", "_Performance", "_Metrics", "Convention", "VirtualDataSource"]),
        .library(name: "Convention",    targets: ["Convention"]),
        .library(name: "NetCDF",        targets: ["NetCDF"]),
        .library(name: "_Metrics",      targets: ["_Metrics"]),
        .library(name: "_Performance",  targets: ["_Performance"]),
        .library(name: "Visualisation", targets: ["Visualisation"]),
        .library(name: "VirtualDataSource", targets: ["VirtualDataSource", "NetCDF"]),
        

    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/patrick-zippenfenig/SwiftNetCDF.git", from: "1.0.0"),
    ],
    targets: [
        // Libaries
        .target(name: "Convention",    dependencies: ["_Performance"]),
        .target(name: "MeteoSwift",    dependencies: ["NetCDF", "Convention"]),
        .target(name: "_Metrics",      dependencies: []),
        .target(name: "Visualisation", dependencies: ["_Performance", "_Metrics"]),
        .target(name: "VirtualDataSource", dependencies: ["NetCDF", "_Performance", "Convention"]),
        
        .target(name: "NetCDF",       dependencies: ["SwiftNetCDF", "_Performance"], cSettings: [.unsafeFlags([])]), //-warn-concurrency", "-Xfrontend
        .target(name: "_Performance", dependencies: [], cSettings: [.unsafeFlags([])]), //-warn-concurrency", "-Xfrontend
        
    
        // Executables
        .executableTarget(name: "NetCDFTestExec",       dependencies: ["NetCDF", "_Metrics", "MeteoSwift"]),
        .executableTarget(name: "_PerformanceTestExec", dependencies: ["_Metrics", "_Performance"]),
        .executableTarget(name: "DataAnalysis",         dependencies: ["_Metrics", "_Performance", "NetCDF"]),
        
        // Test Targets
        .testTarget(name: "MeteoSwiftTests", dependencies: ["MeteoSwift", "Convention"]),
        .testTarget(name: "VirtualDataSourceTests", dependencies: ["VirtualDataSource"]),

    ]
)
