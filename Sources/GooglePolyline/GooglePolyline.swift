//
//  GooglePolyline.swift
//
//  Created by Nicolas Zimmer on 20.03.23.
//

import MapKit

public class GooglePolyline {
    
    public enum SimplificationFactor {
        case automatic(maxLength:Int)
        case value(Double)
    }
    
    private let simplificationFactor: SimplificationFactor
    
    public init(simplificationFactor: SimplificationFactor = .value(1)) {
        self.simplificationFactor = simplificationFactor
    }
    
    public func encode(locations: [CLLocation]) -> String {
        
        var factor: Double
        switch simplificationFactor {
        case .automatic(let maxLength):
            factor = calculateSimplificationFactor(locations: locations, maxLength: maxLength)
        case .value(let value):
            factor = value
        }
        
        let simplifiedLocations = factor != 1 ? simplify(locations, tolerance: factor) : locations
        
        return self._encode(locations: simplifiedLocations)
    }
    
    private func _encode(locations: [CLLocation]) -> String {
        
        var coordinateString = ""
        if locations.isEmpty { return coordinateString }
        var lastLat = 0
        var lastLng = 0
        
        for location in locations {
            let lat = Int(round(location.coordinate.latitude * 1e5))
            let lng = Int(round(location.coordinate.longitude * 1e5))
            
            let dLat = lat - lastLat
            let dLng = lng - lastLng
            
            coordinateString += encodeCoordinate(dLat)
            coordinateString += encodeCoordinate(dLng)
            
            lastLat = lat
            lastLng = lng
        }
        
        return coordinateString
    }
    
    public func decode(polyline: String) -> [CLLocation] {
        var locations: [CLLocation] = []
        
        var index = polyline.startIndex
        var lat = 0
        var lng = 0
        
        while index < polyline.endIndex {
            let (nextLat, newIndex) = decodeCoordinate(polyline, index)
            index = newIndex
            lat += nextLat
            
            let (nextLng, newIndex2) = decodeCoordinate(polyline, index)
            index = newIndex2
            lng += nextLng
            
            let location = CLLocation(latitude: Double(lat) / 1e5, longitude: Double(lng) / 1e5)
            locations.append(location)
        }
        
        return locations
    }
    
    public func decodeToMKPolyline(polyline: String) -> MKPolyline {
        let locations = decode(polyline: polyline)
        let coordinates = locations.map { $0.coordinate }
        return MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
    
    private func encodeCoordinate(_ value: Int) -> String {
        var intValue = value << 1
        if value < 0 {
            intValue = ~intValue
        }
        var result = ""
        
        while intValue >= 0x20 {
            result += String(UnicodeScalar((0x20 | (intValue & 0x1f)) + 63)!)
            intValue >>= 5
        }
        
        result += String(UnicodeScalar(intValue + 63)!)
        return result
    }
    
    private func decodeCoordinate(_ string: String, _ index: String.Index) -> (Int, String.Index) {
        var result = 0
        var shift = 0
        var newIndex = index
        
        while true {
            let byte = string[newIndex].asciiValue! - 63
            newIndex = string.index(after: newIndex)
            result |= (Int(byte) & 0x1f) << shift
            shift += 5
            
            if byte < 0x20 {
                break
            }
        }
        
        let coordinate = (result & 1) != 0 ? ~(result >> 1) : (result >> 1)
        return (coordinate, newIndex)
    }
    
    private func simplify(_ locations: [CLLocation], tolerance: Double) -> [CLLocation] {
        guard !locations.isEmpty else { return [] }
        
        let line = MKPolyline(coordinates: locations.map { $0.coordinate }, count: locations.count)
        let simplifiedLine = line.simplified(tolerance: tolerance)
        
        var coordinates = [CLLocationCoordinate2D](repeating: CLLocationCoordinate2D(), count: simplifiedLine.pointCount)
        simplifiedLine.getCoordinates(&coordinates, range: NSRange(location: 0, length: simplifiedLine.pointCount))
        
        return coordinates.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
    }
    
    private func calculateSimplificationFactor(locations: [CLLocation], maxLength:Int = 2048) -> Double {
        var factor = 1.0
        var encodedString = _encode(locations: locations)
        var simplified:[CLLocation] = []

        while encodedString.count > maxLength {
            factor += 0.5
            simplified = simplify(locations, tolerance: factor)
            encodedString = _encode(locations: simplified)
        }
        
        return factor
    }
}

