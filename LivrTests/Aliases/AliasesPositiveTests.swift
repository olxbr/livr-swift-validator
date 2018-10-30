//
//  AliasesPositiveTests.swift
//  LivrTests
//
//  Created by Felipe Lefèvre Marino on 10/7/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

import XCTest 
@testable import Livr

class AliasesPositiveTests: XCTestCase {

    func testAdultAge() {
        validate(testSuiteAt: .resourcesPath + "01-adult_age")
    }
    
    func testAddress() {
        validate(testSuiteAt: .resourcesPath + "02-address")
    }
    
    func testAdultAgeInUser() {
        validate(testSuiteAt: .resourcesPath + "03-adult_age_in_user")
    }
    
    func testAliasRuleAsObject() {
        var validator = LIVR.validator(validationRules: getRules())
        validator.register(customRule: AdultAge())
        
        let output = try? validator.validate(data: getInput())
        
        XCTAssertNotNil(output as Any?)
        XCTAssertNil(validator.errors)
    }
}

extension AliasesPositiveTests {
    
    func getRules() -> [String: Any?] {
        return ["first_name": "required",
                "age": "adult_age",
                "last_name": ["required"],
                "middle_name": [["required": []]],
                "salary": ["required": []]]
    }
    
    func getInput() -> [String: Any?] {
        return ["first_name": "Vasya",
                "last_name": "Pupkin",
                "middle_name": "Some",
                "age": "18",
                "salary": 0]
    }
}

// MARK: - Private Constants
private extension String {
    static let resourcesPath = "resources/aliases_positive/"
}
