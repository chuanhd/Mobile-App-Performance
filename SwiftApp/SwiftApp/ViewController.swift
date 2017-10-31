//
//  Copyright (c) 2015 Harry Cheung
//

import UIKit

class ViewController: UIViewController {
  
  var track: Track?
  var points: [Point] = []

  @IBOutlet weak var label1000: UILabel!
  @IBOutlet weak var label10000: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let trackJSON = ""
      + "{"
      +   "\"track\": {"
      +     "\"id\": \"1000\","
      +     "\"name\": \"Test Raceway\","
      +     "\"gates\": ["
      +       "{"
      +       "\"type\": \"SPLIT\","
      +       "\"split_number\": \"1\","
      +       "\"latitude\": \"37.451775\","
      +       "\"longitude\": \"-122.203657\","
      +       "\"bearing\": \"136\""
      +       "},"
      +       "{"
      +       "\"type\": \"SPLIT\","
      +       "\"split_number\": \"2\","
      +       "\"latitude\": \"37.450127\","
      +       "\"longitude\": \"-122.205499\","
      +       "\"bearing\": \"326\""
      +       "},"
      +       "{"
      +       "\"split_number\": \"3\","
      +       "\"type\": \"START_FINISH\","
      +       "\"latitude\": \"37.452602\","
      +       "\"longitude\": \"-122.207069\","
      +       "\"bearing\": \"32\""
      +       "}"
      +     "]"
      +   "}"
      + "}"
    
    do {
        track = try Track(jsonData: trackJSON.data(using: String.Encoding.utf8)!)
        
        let lapsFilePath = Bundle.main.path(forResource: "multi_lap_session", ofType: "csv", inDirectory: "Data")!
        
        let contents = try String(contentsOfFile: lapsFilePath, encoding: String.Encoding.utf8)
        let lines = contents.components(separatedBy: "\n")
        for line in lines {
            let parts = line.components(separatedBy: ",")
            points.append(Point(
                latitude: Double(parts[0])!,
                longitude: Double(parts[1])!,
                speed: Double(parts[2])!,
                bearing: Double(parts[3])!,
                horizontalAccuracy: 5.0,
                verticalAccuracy: 15.0,
                timestamp: 0))
        }
    } catch {
        
    }
    
    
  }
  
  @IBAction func run1000(sender: AnyObject) {
    label1000.text = String(format: "%0.03f", arguments: [run(count: 1000)])
  }

  @IBAction func run10000(sender: AnyObject) {
    label10000.text = String(format: "%0.03f", arguments: [run(count: 10000)])
  }
  
  func run(count: Int) -> Double {
    let start = NSDate().timeIntervalSince1970
    var startTime = start
    for _ in 1...count {
        SessionManager.instance.startSession(track: track!)
      for point in points {
        SessionManager.instance.gps(point.latitudeDegrees(), point.longitudeDegrees(), point.speed, point.bearing, horizontalAccuracy: point.hAccuracy, verticalAccuracy: point.vAccuracy, timestamp: startTime)
        startTime += 1
      }
      SessionManager.instance.endSession()
    }
    return NSDate().timeIntervalSince1970 - start
  }
}

