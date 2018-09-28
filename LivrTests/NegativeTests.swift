//
//  LivrTests.swift
//  LivrTests
//
//  Created by Felipe Lefèvre Marino on 9/20/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

import XCTest
@testable import Livr

class NegativeTests: XCTestCase {
    
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
    
    func testEmail() {
        validate(testSuiteAt: .resourcesPath + "16-email")
    }
    
    func testISODate() {
        validate(testSuiteAt: .resourcesPath + "24-iso_date")
    }
    
    func testNotEmptyList() {
        validate(testSuiteAt: .resourcesPath + "22-not_empty_list")
    }
    
    func testAnyObject() {
        validate(testSuiteAt: .resourcesPath + "27-any_object")
    }
    
    func testEq() {
        validate(testSuiteAt: .resourcesPath + "25-eq")
    }
    
    func testOneOf() {
        validate(testSuiteAt: .resourcesPath + "03-one_of")
    }
    
    func testMaxLength() {
        validate(testSuiteAt: .resourcesPath + "05-max_length")
    }
    
    func testMinLength() {
        validate(testSuiteAt: .resourcesPath + "04-min_length")
    }
    
    func testLengthBetween() {
        validate(testSuiteAt: .resourcesPath + "07-length_between")
    }
    
    func testLengthEqual() {
        validate(testSuiteAt: .resourcesPath + "06-length_equal")
    }
    
    func testLike() {
        validate(testSuiteAt: .resourcesPath + "08-like")
    }
}

// MARK: - Private Constants
private extension String {
    static let resourcesPath = "resources/negative/"
}
