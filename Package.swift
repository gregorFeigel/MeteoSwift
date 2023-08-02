// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MeteoSwift",
    products: [
        .library(name: "MeteoSwift" ,  targets: ["MeteoSwift", "_Performance", "_Metrics"]),
        .library(name: "NetCDF",       targets: ["NetCDF", "_Performance"]),
        .library(name: "_Metrics",     targets: ["_Metrics"]),
        .library(name: "_Performance", targets: ["_Performance", "_Metrics"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/patrick-zippenfenig/SwiftNetCDF.git", from: "1.0.0"),
    ],
    targets: [
        // Libaries
        .target(name: "MeteoSwift",   dependencies: []),
        .target(name: "_Metrics",     dependencies: []),
        .target(name: "NetCDF",       dependencies: ["SwiftNetCDF", "_Performance"],
                cSettings: [.unsafeFlags(["-warn-concurrency", "-Xfrontend"])]),

        .target(name: "_Performance",
                dependencies: [],
                cSettings: [.unsafeFlags(["-warn-concurrency", "-Xfrontend"])]),
        
    
        // Executables
        .executableTarget(name: "NetCDFTestExec",       dependencies: ["NetCDF", "_Metrics", "MeteoSwift"]),
        .executableTarget(name: "_PerformanceTestExec", dependencies: ["_Metrics", "_Performance"]),
        .executableTarget(name: "DataAnalysis",         dependencies: ["_Metrics", "_Performance", "NetCDF"]),
        
        // Test Targets
        .testTarget(name: "MeteoSwiftTests", dependencies: ["MeteoSwift"]),
    ]
)
