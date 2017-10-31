//
//  Copyright (c) 2015 Harry Cheung
//

import UIKit

enum GateType: String, CustomStringConvertible {
  case SPLIT = "SPLIT", START = "START", FINISH = "FINISH", START_FINISH = "START_FINISH"
  
  var description : String {
    switch self {
    case .SPLIT: return "SPLIT"
    case .START: return "START"
    case .FINISH: return "FINISH"
    case .START_FINISH: return "START_FINISH"
    }
  }
}


final class Gate {
  
  let LINE_WIDTH:    Double = 30
  let BEARING_RANGE: Double = 5
  var location: Point
  let type: GateType
  let splitNumber: Int
  var leftPoint, rightPoint: Point?
  
  init(type: GateType, splitNumber: Int, latitude: Double, longitude: Double, bearing: Double) {
    self.type = type
    self.splitNumber = splitNumber
    self.location = Point(latitude: latitude, longitude: longitude, inRadians: false)
    let leftBearing  = bearing - 90 < 0 ? bearing + 270 : bearing - 90
    let rightBearing = bearing + 90 > 360 ? bearing - 270 : bearing + 90
    self.leftPoint  = location.destination(leftBearing, LINE_WIDTH / 2)
    self.rightPoint = location.destination(rightBearing, LINE_WIDTH / 2)
    self.location.bearing = bearing
  }
  
    func crossed(_ start: Point,_ destination: Point,_ cross: inout Point) -> Bool {
    let pathBearing = start.bearingTo(point: destination)
    if pathBearing > (location.bearing - BEARING_RANGE) &&
      pathBearing < (location.bearing + BEARING_RANGE) {
        if Point.intersectSimple(leftPoint!, rightPoint!, start, destination, &cross) {
            let distance     = start.distanceTo(point: cross)
        let timeSince    = destination.timestamp - start.timestamp
        let acceleration = (destination.speed - start.speed) / timeSince
        let timeCross    = Physics.time(distance, start.speed, acceleration)
        cross.generated   = true
        cross.speed       = start.speed + acceleration * timeCross
        cross.bearing     = start.bearingTo(point: destination)
        cross.timestamp   = start.timestamp + timeCross
        cross.lapDistance = start.lapDistance + distance
        cross.lapTime     = start.lapTime + timeCross
        cross.splitTime   = start.splitTime + timeCross
        return true
      }
    }
    return false
  }
}
