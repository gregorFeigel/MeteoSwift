import XCTest
@testable import MeteoSwift

final class MeteoSwift_Unti_Test: XCTestCase {

    struct x: Coordinate {
        var longitude: Double = 7.5
        var latitude: Double = 47.9
    }
    
    func test_unit() {
        let solar = Solar(coordinate: x())
        print(solar?.isSunsetEvent(within: 60))
    }
    
}
