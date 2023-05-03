//
//  AllRequiredTests.swift
//  LivrTests
//
//  Created by Felipe Lefèvre Marino on 11/12/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

import XCTest
@testable import Livr

class AllRequiredTests: XCTestCase {

    func testAllRequiredSetToTrue() {
        let rules: [String: Any?] = ["field-1": ["positive_integer"],
                                     "field-2": ["nested_object": ["string_value": "string"]],
                                     "field-3": ["list_of": "required"]]
        
        let input: [String: Any?] = ["field-1": nil,
                                     "field-2": nil,
                                     "field-3": ["white_space_in_the_end ", " white_space_in_the_beginning"]]
        
        
        var validator = LIVR.validator(validationRules: rules)
        validator.allRequired = true
        
        do {
            try validator.validate(data: input)
            
            guard let errors = validator.errors else {
                XCTFail("errors should not be nil")
                return
            }
            
            XCTAssertEqual(errors["field-1"] as? String, "REQUIRED")
            XCTAssertEqual(errors["field-2"] as? String, "REQUIRED")
            XCTAssertEqual(errors.count, 2)
        } catch { XCTFail("Error while trying to validate") }
    }
}
