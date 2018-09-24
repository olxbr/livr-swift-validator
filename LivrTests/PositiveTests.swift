//
//  LivrTests.swift
//  LivrTests
//
//  Created by Felipe Lefèvre Marino on 9/20/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

import XCTest
@testable import Livr

class PositiveTests: XCTestCase {
    
    func testRequired() {
        validate(testSuiteAt: .resourcesPath + "01-required")
    }
    
    func testNotEmpty() {
        validate(testSuiteAt: .resourcesPath + "02-not_empty")
    }
    
    func testInteger() {
        validate(testSuiteAt: .resourcesPath + "09-integer")
    }
}



// MARK: - Private Constants
private extension String {
    static let resourcesPath = "resources/positive/"
}
