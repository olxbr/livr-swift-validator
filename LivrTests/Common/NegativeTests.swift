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
    
    func testMaxNumber() {
        validate(testSuiteAt: .resourcesPath + "13-max_number")
    }
    
    func testMinNumber() {
        validate(testSuiteAt: .resourcesPath + "14-min_number")
    }
    
    func testNumberBetween() {
        validate(testSuiteAt: .resourcesPath + "15-number_between")
    }
    
    func testEqualToField() {
        validate(testSuiteAt: .resourcesPath + "17-equal_to_field")
    }
    
    func testNestedObject() {
        validate(testSuiteAt: .resourcesPath + "18-nested_object")
    }
    
    func testVariableObject() {
        validate(testSuiteAt: .resourcesPath + "28-variable_object")
    }
    
    func testListOf() {
        validate(testSuiteAt: .resourcesPath + "19-list_of")
    }
    
    func testFirstErrorOfField() {
        let rules: [String: Any?] = ["number": ["positive_integer", ["min_number": 5]]]
        
        let validator = LIVR.validator(validationRules: rules, isAutoTrim: false)
        _ = try? validator.validate(data: ["number": "abc"])
        
        XCTAssertEqual(validator.errors?["number"] as? String, "NOT_POSITIVE_INTEGER")
    }
    
    func testListsWithValidItemsBeforeErrors() {
        let rules: [String: Any?] = ["list": ["list_of": "integer"],
                                     "objects": ["list_of_objects": ["id": "integer"]]]
        let input: [String: Any?] = ["list": [1, "x"],
                                     "objects": [["id": 1], ["id": "x"]]]
        
        let validator = LIVR.validator(validationRules: rules, isAutoTrim: false)
        guard let output = try? validator.validate(data: input) else {
            XCTFail("validate should not throw")
            return
        }
        XCTAssertNil(output)
        
        let errors = validator.errors ?? [:]
        let expectedErrors: [String: Any] = ["list": [NSNull(), "NOT_INTEGER"],
                                             "objects": [NSNull(), ["id": "NOT_INTEGER"]]]
        XCTAssertTrue(errors.isEqual(to: expectedErrors), "\(errors)")
    }
    
    func testListOfObjects() {
        validate(testSuiteAt: .resourcesPath + "20-list_of_objects")
    }
    
    func testListOfDifferentObjects() {
        validate(testSuiteAt: .resourcesPath + "21-list_of_different_objects")
    }
    
    func testOr() {
        validate(testSuiteAt: .resourcesPath + "29-or")
    }
}

// MARK: - Private Constants
private extension String {
    static let resourcesPath = "resources/negative/"
}
