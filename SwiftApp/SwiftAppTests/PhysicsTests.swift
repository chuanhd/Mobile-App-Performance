//
//  Copyright (c) 2015 Harry Cheung
//

import UIKit
import XCTest

class PhysicsTests: XCTestCase {
  
  func testDistance() {
    XCTAssertEqual(Physics.distance(0, 0, 0), 0.0)
    XCTAssertEqual(Physics.distance(1, 1, 1), 1.5)
    XCTAssertEqual(Physics.distance(2, 2, 2), 8.0)
    XCTAssertEqual(Physics.distance(3, 0, 3), 9.0)
  }
  
  func testTime() {
    XCTAssertEqual(Physics.time(1.5, 1, 1), 1.0)
    XCTAssertEqual(Physics.time(8.0, 2, 2), 2.0)
    XCTAssertEqual(Physics.time(9.0, 3, 0), 3.0)
  }

}
