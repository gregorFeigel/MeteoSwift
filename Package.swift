// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MeteoSwift",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MeteoSwift",
            targets: ["MeteoSwift"]),
        
            .library(
                name: "NetCDF",
                targets: ["NetCDF"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/patrick-zippenfenig/SwiftNetCDF.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        
        .target(
            name: "MeteoSwift",
            dependencies: []),
 
            .target(
                name: "_Metrics",
                dependencies: []),
        
            .target(
                name: "_Performance",
                dependencies: []),
        
            .target(
                name: "NetCDF",
                dependencies: ["SwiftNetCDF", "_Performance"]),
        
            .executableTarget(
                name: "NetCDFTestExec",
                dependencies: ["NetCDF", "_Metrics", "MeteoSwift"]
            ),
        
            .executableTarget(
                name: "_PerformanceTestExec",
                dependencies: ["_Metrics", "_Performance"]
            ),
        
            .executableTarget(
                name: "DataAnalysis",
                dependencies: ["_Metrics", "_Performance", "NetCDF"]
            ),
        
        .testTarget(
            name: "MeteoSwiftTests",
            dependencies: ["MeteoSwift"]),
    ]
)
