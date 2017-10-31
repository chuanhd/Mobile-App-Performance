//
//  Copyright (c) 2015 Harry Cheung
//

import UIKit

func toRadians(value: Double) -> Double {
  return value * Double.pi / 180.0
}

func toDegrees(value: Double) -> Double {
  return value * 180.0 / Double.pi
}

func == (left: Point, right: Point) -> Bool {
  return (left.latitudeDegrees() == right.latitudeDegrees()) && (left.longitudeDegrees() == right.longitudeDegrees())
}


struct Point: Equatable {
  
  let RADIUS: Double = 6371000
  
  var latitude: Double
  var longitude: Double
  var speed: Double
  var bearing: Double
  var hAccuracy: Double
  var vAccuracy: Double
  var timestamp: Double
  var lapDistance: Double
  var lapTime: Double
  var splitTime: Double
  var acceleration: Double
  var generated: Bool = false
  
  init() {
    self.init(latitude: 0, longitude: 0, inRadians: false)
  }
  
  init (latitude _latitude: Double,longitude _longitude: Double, inRadians _inRadians: Bool) {
    if _inRadians {
        self.latitude  = _latitude
        self.longitude = _longitude
    } else {
        self.latitude  = toRadians(value: _latitude)
        self.longitude = toRadians(value: _longitude)
    }
    self.speed        = 0
    self.bearing      = 0
    self.hAccuracy    = 0
    self.vAccuracy    = 0
    self.timestamp    = 0
    self.lapDistance  = 0
    self.lapTime      = 0
    self.splitTime    = 0
    self.acceleration = 0
  }
  
   init (latitude _latitude: Double,longitude _longitude: Double) {
    self.init(latitude: _latitude, longitude: _longitude, inRadians: false)
  }
  
   init (latitude _latitude: Double,longitude _longitude: Double,bearing _bearing: Double) {
    self.init(latitude: _latitude, longitude: _longitude, inRadians: false)
    self.bearing = _bearing
  }
  
   init (latitude _latitude: Double,longitude _longitude: Double,speed _speed: Double,bearing _bearing: Double,
    horizontalAccuracy: Double, verticalAccuracy: Double, timestamp: Double) {
      self.init(latitude: _latitude, longitude: _longitude, inRadians: false)
      self.speed     = _speed
      self.bearing   = _bearing
      self.hAccuracy = horizontalAccuracy
      self.vAccuracy = verticalAccuracy
      self.timestamp = timestamp
  }
  
  mutating func setLapTime(startTime: Double, splitStartTime: Double) {
    lapTime = timestamp - startTime
    splitTime = timestamp - splitStartTime
  }
  
  func roundValue(value: Double) -> Double {
    return round(value * 1000000.0) / 1000000.0
  }
  
  func latitudeDegrees() -> Double {
    return roundValue(value: toDegrees(value: latitude))
  }
  
  func longitudeDegrees() -> Double {
    return roundValue(value: toDegrees(value: longitude))
  }
  
  func subtract(point: Point) -> Point {
    return Point(latitude: latitude - point.latitude, longitude: longitude - point.longitude, inRadians: true)
  }
  
  func bearingTo(point: Point, inRadians: Bool) -> Double {
    let φ1 = latitude
    let φ2 = point.latitude
    let Δλ = point.longitude - longitude
    
    let y = sin(Δλ) * cos(φ2)
    let x = cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(Δλ)
    let θ = atan2(y, x)
    
    if (inRadians) {
        return roundValue(value: (θ + 2 * Double.pi).truncatingRemainder(dividingBy: Double.pi))
    } else {
        return roundValue(value: (toDegrees(value: θ) + 2 * 360).truncatingRemainder(dividingBy: 360))
    }
  }
  
  func bearingTo(point: Point) -> Double {
    return bearingTo(point: point, inRadians: false)
  }
  
  func destination(_ bearing: Double,_ distance: Double) -> Point {
    let θ  = toRadians(value: bearing)
    let δ  = distance / RADIUS
    let φ1 = latitude
    let λ1 = longitude
    let φ2 = asin(sin(φ1) * cos(δ) + cos(φ1) * sin(δ) * cos(θ))
    var λ2 = λ1 + atan2(sin(θ) * sin(δ) * cos(φ1), cos(δ) - sin(φ1) * sin(φ2))
    λ2 = (λ2 + 3.0 * Double.pi).truncatingRemainder(dividingBy: (2.0 * Double.pi)) - Double.pi // normalise to -180..+180

    return Point(latitude: φ2, longitude: λ2, inRadians: true)
  }
  
  func distanceTo(point: Point) -> Double {
    let φ1 = latitude
    let λ1 = longitude
    let φ2 = point.latitude
    let λ2 = point.longitude
    let Δφ = φ2 - φ1
    let Δλ = λ2 - λ1
    
    let a = sin(Δφ / 2) * sin(Δφ / 2) + cos(φ1) * cos(φ2) * sin(Δλ / 2) * sin(Δλ / 2)
    
    return RADIUS * 2 * atan2(sqrt(a), sqrt(1 - a))
  }
  
    static func intersectSimple(_ p: Point,_ p2: Point,_ q: Point,_ q2: Point,_ intersection: inout Point) -> Bool {
    let s1_x = p2.longitude - p.longitude
    let s1_y = p2.latitude - p.latitude
    let s2_x = q2.longitude - q.longitude
    let s2_y = q2.latitude - q.latitude
    
    let den = (-s2_x * s1_y + s1_x * s2_y)
    if den == 0 { return false }
    
    let s = (-s1_y * (p.longitude - q.longitude) + s1_x * (p.latitude - q.latitude)) / den
    let t = ( s2_x * (p.latitude - q.latitude) - s2_y * (p.longitude - q.longitude)) / den
    
    if s >= 0 && s <= 1 && t >= 0 && t <= 1 {
      intersection.latitude = p.latitude + (t * s1_y)
      intersection.longitude = p.longitude + (t * s1_x)
      return true
    }
    
    return false
  }
  
}
