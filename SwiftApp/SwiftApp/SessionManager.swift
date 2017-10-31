//
//  Copyright (c) 2015 Harry Cheung
//

import Foundation
import UIKit

// Singleton
private let _SessionManagerSharedInstance = SessionManager()

final class SessionManager {
  
  var session: Session? = nil
  var currentLap: Lap?
  var bestLap: Lap?
  var lastPoint: Point = Point()
  var bestIndex: Int = 0
  var nextGate: Gate?
  var gateIter: Int = 0
  var splits:   [Double] = []
  var splitGaps: [Double] = []
  var splitStartTime: Double = 0
  var splitNumber: Int = 0
  var track: Track?
  var currentSplit: Int = 0
  var lapNumber: Int = 0
  var gap: Double = 0
  
  class var instance: SessionManager { return _SessionManagerSharedInstance }
  
  func startSession(track: Track) {
    if session == nil {
      self.track = track
      session = Session(track: track)
      currentLap = Lap(
        session: session!,
        track: track,
        startTime: session!.startTime,
        lapNumber: 0)
      session!.laps.append(currentLap!)
        splits = [Double](repeating: 0, count: track.numSplits())
        splitGaps = [Double](repeating: -1, count: track.numSplits())
      splitStartTime = session!.startTime
      splitNumber = 0
      currentSplit = 0
      lapNumber = 0
      gap = 0
      bestIndex = 0
      nextGate = track.start
    }
  }
  
  func endSession() {
    session = nil
    currentLap = nil
    bestLap = nil
  }
  
  func gps(_ latitude: Double,_ longitude: Double,_ speed: Double,_ bearing: Double,
    horizontalAccuracy: Double, verticalAccuracy: Double, timestamp: Double) {
    var point = Point(latitude: latitude, longitude: longitude, speed: speed,
      bearing: bearing, horizontalAccuracy: horizontalAccuracy,
      verticalAccuracy: verticalAccuracy, timestamp: timestamp)
    if currentLap!.points.count != 0 {
      var cross: Point = Point()
        if nextGate!.crossed(lastPoint, point, &cross) {
            currentLap!.add(point: cross)
        currentLap!.splits[currentSplit] = cross.splitTime
        switch nextGate!.type {
        case .START_FINISH, .FINISH:
          if currentLap!.points[0].generated {
            currentLap!.valid = true
            if bestLap == nil || currentLap!.duration < bestLap!.duration {
              bestLap = currentLap
            }
          }
          fallthrough
        case .START:
          lapNumber += 1
          currentLap = Lap(session: session!, track: track!, startTime: cross.timestamp, lapNumber: lapNumber)
          lastPoint = Point(latitude: cross.latitudeDegrees(),
            longitude: cross.longitudeDegrees(),
            speed: cross.speed,
            bearing: cross.bearing,
            horizontalAccuracy: cross.hAccuracy,
            verticalAccuracy: cross.vAccuracy,
            timestamp: cross.timestamp)
          lastPoint.lapDistance = 0
          lastPoint.lapTime = 0
          lastPoint.generated = true
          currentLap!.add(point: lastPoint);
          session!.laps.append(currentLap!)
          gap = 0
          for (index, _) in splitGaps.enumerated() {
            splitGaps[index] = 0
          }
          bestIndex = 0
          currentSplit = 0
        case .SPLIT:
          if bestLap != nil {
            splitGaps[currentSplit] = currentLap!.splits[currentSplit] - bestLap!.splits[currentSplit]
          }
          currentSplit += 1
        }
        splitStartTime = cross.timestamp
        nextGate = track!.gates[currentSplit]
      }
      if bestLap != nil && bestIndex < bestLap!.points.count {
        while bestIndex < bestLap!.points.count {
          let refPoint = bestLap!.points[bestIndex]
          if refPoint.lapDistance > currentLap!.distance {
            let lastRefPoint = bestLap!.points[bestIndex - 1]
            let distanceToLastRefPoint = currentLap!.distance - lastRefPoint.lapDistance
            if (distanceToLastRefPoint > 0) {
              let sinceLastRefPoint = distanceToLastRefPoint / point.speed
              gap = point.lapTime - sinceLastRefPoint - lastRefPoint.lapTime
              splitGaps[splitNumber] = point.splitTime - sinceLastRefPoint - lastRefPoint.splitTime
            }
            break
          }
          bestIndex += 1
        }
      }
        point.lapDistance = lastPoint.lapDistance + lastPoint.distanceTo(point: point)
        point.setLapTime(startTime: currentLap!.startTime, splitStartTime: splitStartTime)
    }
    currentLap!.add(point: point)
    lastPoint = point
  }

}
