//
//  LivrCommonCustomRulesPositiveTests.swift
//  LivrCommonCustomRulesPositiveTests
//
//  Created by Felipe Marino on 03/07/19.
//  Copyright © 2019 Zap SA Internet. All rights reserved.
//

import XCTest
@testable import LivrCommonCustomRules
import Livr

class LivrCommonCustomRulesPositiveTests: XCTestCase {

    func testGreatherThanOrEqualToWithArray() {
        let rules: [String: Any] = ["usableAreas": ["required", "not_empty_list",
                                                    ["list_of": [["number_between": [10, 100]], "not_empty"]]],
                                    "totalAreas": ["greater_eq_than_field":  "usableAreas"]]
        
        var validator = LIVR.validator(validationRules: rules)
        validator.register(customRule: CustomRules.GreaterThanOrEqualToField())
        try? validator.validate(data: ["usableAreas": [10, 11, 13], "totalAreas": [10, 12, 14]])
        
        XCTAssertNil(validator.errors)
        XCTAssertNotNil(validator.output)
    }
    
    func testGreatherThanOrEqualToWithPrimitiveValue() {
        let rules: [String: Any] = ["usableAreas": ["required", ["number_between": [10, 100]], "not_empty"],
                                    "totalAreas": ["greater_eq_than_field":  "usableAreas"]]
        
        var validator = LIVR.validator(validationRules: rules)
        validator.register(customRule: CustomRules.GreaterThanOrEqualToField())
        try? validator.validate(data: ["usableAreas": 30, "totalAreas": 30])
        
        XCTAssertNil(validator.errors)
        XCTAssertNotNil(validator.output)
    }
}
