//
//  AutoTrimTests.swift
//  LivrTests
//
//  Created by Felipe Lefèvre Marino on 10/2/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

import XCTest
@testable import Livr

class AutoTrimTests: XCTestCase {
    
    func testAutoTrim() {
        let rules: [String: Any?] = ["field-1": ["required"],
                         "field-2": ["nested_object": ["string_value": "string"]],
                         "field-3": ["list_of": "required"]]
        
        let input: [String: Any?] = ["field-1": " 13",
                           "field-2": ["string_value":" not_trimmed_string "],
                           "field-3": ["white_space_in_the_end ", " white_space_in_the_beginning"]]
        
        
        var validator = LIVR.validator(validationRules: rules)
        guard let optionalOutput = try? validator.validate(data: input), let output = optionalOutput else {
            XCTFail("output should not be nil")
            return
        }

        XCTAssertEqual(output["field-1"] as? String, "13")
        XCTAssertEqual(output["field-2"] as? [String: String], ["string_value": "not_trimmed_string"])
        XCTAssertEqual(output["field-3"] as? [String], ["white_space_in_the_end", "white_space_in_the_beginning"])
    }
    
    func testAutoTrimBeforeValidation() {
        let rules: [String: Any?] = ["code": "required",
                                     "password": ["required", ["min_length": 3]],
                                     "address": ["nested_object": ["street": ["min_length": 5]]]]
        
        let input: [String: Any?] = ["code": "  ",
                                     "password": " 12  ",
                                     "address": ["street": "  hell "]]
        
        let validator = LIVR.validator(validationRules: rules, isAutoTrim: true)
        guard let output = try? validator.validate(data: input) else {
            XCTFail("validate should not throw")
            return
        }
        XCTAssertNil(output)
        
        let errors = validator.errors ?? [:]
        let expectedErrors: [String: Any] = ["code": "REQUIRED",
                                             "password": "TOO_SHORT",
                                             "address": ["street": "TOO_SHORT"]]
        XCTAssertTrue(errors.isEqual(to: expectedErrors), "\(errors)")
    }
    
    func testAutoTrimOfComparedFields() {
        let rules: [String: Any?] = ["password": "required",
                                     "password2": ["equal_to_field": "password"]]
        
        let validator = LIVR.validator(validationRules: rules, isAutoTrim: true)
        let output = try? validator.validate(data: ["password": " 1234 ", "password2": " 1234 "])
        
        XCTAssertNil(validator.errors)
        XCTAssertEqual(output??["password2"] as? String, "1234")
    }
    
    func testAutoTrimWithAllRequired() {
        let validator = LIVR.validator(validationRules: ["field": "string"], isAutoTrim: true)
        validator.allRequired = true
        _ = try? validator.validate(data: ["field": "  "])
        
        XCTAssertEqual(validator.errors?["field"] as? String, "REQUIRED")
    }
    
    func testAutoTrimKeepsNumbers() {
        let rules: [String: Any?] = ["field-1": ["required"],
                                     "field-2": ["trim"]]
        
        let input: [String: Any?] = ["field-1": 1.2,
                                     "field-2": 1.2]
        
        let validator = LIVR.validator(validationRules: rules)
        guard let optionalOutput = try? validator.validate(data: input), let output = optionalOutput else {
            XCTFail("output should not be nil")
            return
        }
        
        XCTAssertEqual(output["field-1"] as? Double, 1.2)
        XCTAssertEqual(output["field-2"] as? String, "1.2")
    }
}
