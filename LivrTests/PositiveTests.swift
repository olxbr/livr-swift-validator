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
    
    func testDecimal() {
        validate(testSuiteAt: .resourcesPath + "11-decimal")
    }
    
    func testPositiveInteger() {
        validate(testSuiteAt: .resourcesPath + "10-positive_integer")
    }
    
    func testPositiveDecimal() {
        validate(testSuiteAt: .resourcesPath + "12-positive_decimal")
    }
    
    func testString() {
        validate(testSuiteAt: .resourcesPath + "26-string")
    }
    
    func testUrl() {
        validate(testSuiteAt: .resourcesPath + "23-url")
    }
}



// MARK: - Private Constants
private extension String {
    static let resourcesPath = "resources/positive/"
}
