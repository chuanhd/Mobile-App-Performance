//
//  Copyright (c) 2015 Harry Cheung
//

import UIKit

final class Track {
  
  var gates: [Gate] = []
  let id: Int!
  let name: String!
  var start: Gate!
  
  init(jsonObject: Dictionary<String, Any>) {
    let jsonTrack = jsonObject["track"] as! Dictionary<String, Any>
    let jsonGates = jsonTrack["gates"] as! Array<Dictionary<String, Any>>
    for i in 0..<jsonGates.count {
      let jsonGate = jsonGates[i]
      let gate = Gate(
        type:        GateType(rawValue: jsonGate["type"] as! String)!,
        splitNumber: Int(jsonGate["split_number"] as? String ?? "") ?? 0,
        latitude:    Double(jsonGate["latitude"] as? String ?? "") ?? 0,
        longitude:   Double(jsonGate["longitude"] as? String ?? "") ?? 0,
        bearing:     Double(jsonGate["bearing"] as? String ?? "") ?? 0)
      if gate.type == GateType.START_FINISH ||
        gate.type == GateType.START {
          start = gate
      }
      gates.append(gate)
    }
    id   = Int(jsonTrack["id"] as? String ?? "") ?? 0
    name = jsonTrack["name"] as! String
    
    assert(id != nil)
    assert(name != nil)
    assert(start != nil)
  }
  
  convenience init(jsonData: Data) throws {
    let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, Any>
    self.init(jsonObject: jsonObject)
  }
  
  convenience init(file filePath: String) throws {
    var error: Error?
    var content = try Data(contentsOf: URL(fileURLWithPath: filePath))
    // TODO: do something with error
    try self.init(jsonData: content)
  }
  
  func numSplits() -> Int {
    return gates.count
  }
  
  func distanceToStart(_ latitude: Double,_ longitude: Double) -> Double {
    return start.location.distanceTo(point: Point(latitude: latitude, longitude: longitude));
  }
}
