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
}

// MARK: - Private Constants
private extension String {
    static let resourcesPath = "resources/aliases_positive/"
}
