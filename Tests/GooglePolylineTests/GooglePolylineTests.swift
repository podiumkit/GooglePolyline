#if canImport(CoreLocation)
import CoreLocation
#endif

import XCTest
@testable import GooglePolyline


final class GooglePolylineTests: XCTestCase {
    
    func testEmptyArrayShouldBeEmptyString() {
        XCTAssertEqual(GooglePolyline().encode(locations: []), "")
    }
    
   
    func testCoordinateToStringNoSimplification() {
        let coordinate = CLLocation(latitude: 52.48855, longitude: 13.34262)
        let encoded = GooglePolyline().encode(locations: [coordinate])
        XCTAssertEqual(encoded, "mtj_Ik~lpA")
    }
    
    func testStringToCoordinateNoSimplification() {
        let coordinate = CLLocation(latitude: 52.48855, longitude: 13.34262)
        let string = "mtj_Ik~lpA"
        let decoded = GooglePolyline().decode(polyline: string).first
        XCTAssertEqual(coordinate.coordinate.longitude, decoded?.coordinate.longitude)
        XCTAssertEqual(coordinate.coordinate.latitude, decoded?.coordinate.latitude)
    }
    
    func testCoordinateToStringNumericSimplification() {
        let coordinate = CLLocation(latitude: 52.48855, longitude: 13.34262)
        let encoded = GooglePolyline(simplificationFactor: .value(2)).encode(locations: [coordinate])
        XCTAssertEqual(encoded, "mtj_Ik~lpA")
    }
    
    func testStringToCoordinateNumericSimplification() {
        let coordinate = CLLocation(latitude: 52.48855, longitude: 13.34262)
        let string = "mtj_Ik~lpA"
        let decoded = GooglePolyline(simplificationFactor: .value(2)).decode(polyline: string).first
        XCTAssertEqual(coordinate.coordinate.longitude, decoded?.coordinate.longitude)
        XCTAssertEqual(coordinate.coordinate.latitude, decoded?.coordinate.latitude)
    }
    
    func testCoordinateToStringAutomaticSimplification() {
        let coordinate = CLLocation(latitude: 52.48855, longitude: 13.34262)
        let encoded = GooglePolyline(simplificationFactor: .automatic(maxLength: 124)).encode(locations: [coordinate])
        XCTAssertEqual(encoded, "mtj_Ik~lpA")
    }
    
    func testStringToCoordinateAutomaticSimplification() {
        let coordinate = CLLocation(latitude: 52.48855, longitude: 13.34262)
        let string = "mtj_Ik~lpA"
        let decoded = GooglePolyline(simplificationFactor: .automatic(maxLength: 124)).decode(polyline: string).first
        XCTAssertEqual(coordinate.coordinate.longitude, decoded?.coordinate.longitude)
        XCTAssertEqual(coordinate.coordinate.latitude, decoded?.coordinate.latitude)
    }
    
}
