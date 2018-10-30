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
}
