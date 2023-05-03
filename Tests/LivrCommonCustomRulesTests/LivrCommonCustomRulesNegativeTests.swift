//
//  LivrCommonCustomRulesNegativeTests.swift
//  LivrCommonCustomRulesNegativeTests
//
//  Created by Felipe Marino on 04/07/19.
//  Copyright © 2019 Zap SA Internet. All rights reserved.
//

import XCTest
@testable import LivrCommonCustomRules
import Livr

class LivrCommonCustomRulesNegativeTests: XCTestCase {
    
    func testGreatherThanOrEqualToWithArray() {
        let rules: [String: Any] = ["usableAreas": ["required", "not_empty_list",
                                                    ["list_of": [["number_between": [10, 100]], "not_empty"]]],
                                    "totalAreas": ["greater_eq_than_field":  "usableAreas"]]
        
        let validator = LIVR.validator(validationRules: rules)
        validator.register(customRule: CustomRules.GreaterThanOrEqualToField())
        _ = try? validator.validate(data: ["usableAreas": [1, 99, 13], "totalAreas": [0, 98, 7]])
        
        XCTAssertNotNil(validator.errors)
        XCTAssertNil(validator.output)
    }
    
    func testGreatherThanOrEqualToWithPrimitiveValue() {
        let rules: [String: Any] = ["usableAreas": ["required", ["number_between": [10, 100]], "not_empty"],
                                    "totalAreas": ["greater_eq_than_field":  "usableAreas"]]
        
        let validator = LIVR.validator(validationRules: rules)
        validator.register(customRule: CustomRules.GreaterThanOrEqualToField())
        _ = try? validator.validate(data: ["usableAreas": 30, "totalAreas": 20])
        
        XCTAssertNotNil(validator.errors)
        XCTAssertNil(validator.output)
    }

    func testRequiredIfWithoutField() {
        let rules: [String: Any] = ["usableAreas": ["required_if": ["totalAreas": "not_empty"]]]

        let validator = LIVR.validator(validationRules: rules)
        validator.register(customRule: CustomRules.RequiredIf())
        _ = try? validator.validate(data: ["totalAreas": 30])

        XCTAssertNotNil(validator.errors)
        XCTAssertNil(validator.output)
    }

    func testNotEmptyListIfWithoutField() {
        let rules: [String: Any] = ["images": ["not_empty_list_if": ["status": ["eq": "ACTIVE"]]]]

        let validator = LIVR.validator(validationRules: rules)
        validator.register(customRule: CustomRules.NotEmptyListIf())
        _ = try? validator.validate(data: ["status": "ACTIVE"])

        XCTAssertNotNil(validator.errors)
        XCTAssertNil(validator.output)
    }
}
