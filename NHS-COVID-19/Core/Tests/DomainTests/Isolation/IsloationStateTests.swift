//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
import TestSupport
import XCTest
@testable import Domain

class IsolationStateTests: XCTestCase {
    
    func testInitializingNotIsolating() {
        let state = IsolationState(logicalState: .notIsolating(finishedIsolationThatWeHaveNotDeletedYet: nil))
        
        TS.assert(state, equals: .noNeedToIsolate)
    }
    
    func testInitializingNotIsolatingWhenNotAcknowledged() {
        let state = IsolationState(logicalState: .isolationFinishedButNotAcknowledged(Isolation(untilStartOfDay: .today, reason: .contactCase)))
        
        TS.assert(state, equals: .noNeedToIsolate)
    }
    
    func testInitializingIsolating() {
        let timeZone = TimeZone(secondsFromGMT: .random(in: 100 ... 1000))!
        let day = LocalDay(year: 2020, month: 3, day: 17, timeZone: timeZone)
        let isolation = Isolation(untilStartOfDay: day, reason: .indexCase(hasPositiveTestResult: false))
        let state = IsolationState(logicalState: .isolating(isolation, endAcknowledged: false, startAcknowledged: true))
        
        TS.assert(state, equals: .isolate(isolation))
    }
    
}
