//
//  MKPolyline+simplified.swift
//
//  Created by Nicolas Zimmer on 20.03.23.
//

import Foundation
import MapKit

extension MKPolyline {
    func simplified(tolerance: Double) -> MKPolyline {
        guard self.pointCount > 2 else { return self }
        let douglasPeucker = DouglasPeucker(points: self.points(), count: self.pointCount, tolerance: tolerance)
        let simplifiedPoints = douglasPeucker.simplify()
        return MKPolyline(points: simplifiedPoints, count: simplifiedPoints.count)
    }
}

class DouglasPeucker {
    private let points: UnsafePointer<MKMapPoint>
    private let count: Int
    private let tolerance: Double
    
    init(points: UnsafePointer<MKMapPoint>, count: Int, tolerance: Double) {
        self.points = points
        self.count = count
        self.tolerance = tolerance
    }
    
    func simplify() -> [MKMapPoint] {
        var result = [MKMapPoint]()
        simplifyRecursive(start: 0, end: count - 1, result: &result)
        return result
    }
    
    private func simplifyRecursive(start: Int, end: Int, result: inout [MKMapPoint]) {
        if start < 0 || end >= count || end <= start {
            return
        }
        
        var maxDistance = 0.0
        var index = 0
        
        let startPoint = points[start]
        let endPoint = points[end]
        
        for i in start + 1..<end {
            let distance = pointLineDistance(point: points[i], lineStart: startPoint, lineEnd: endPoint)
            if distance > maxDistance {
                maxDistance = distance
                index = i
            }
        }
        
        if maxDistance > tolerance {
            simplifyRecursive(start: start, end: index, result: &result)
            result.append(points[index])
            simplifyRecursive(start: index, end: end, result: &result)
        }
    }
    
    private func pointLineDistance(point: MKMapPoint, lineStart: MKMapPoint, lineEnd: MKMapPoint) -> Double {
        let lineLengthSquared = lineStart.distance(to: lineEnd)
        if lineLengthSquared == 0 {
            return point.distance(to: lineStart)
        }
        
        let t = ((point.x - lineStart.x) * (lineEnd.x - lineStart.x) + (point.y - lineStart.y) * (lineEnd.y - lineStart.y)) / lineLengthSquared
        if t < 0 {
            return point.distance(to: lineStart)
        } else if t > 1 {
            return point.distance(to: lineEnd)
        }
        
        let projection = MKMapPoint(x: lineStart.x + t * (lineEnd.x - lineStart.x), y: lineStart.y + t * (lineEnd.y - lineStart.y))
        return point.distance(to: projection)
    }
}
