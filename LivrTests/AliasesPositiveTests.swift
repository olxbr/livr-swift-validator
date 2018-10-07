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
}

// MARK: - Private Constants
private extension String {
    static let resourcesPath = "resources/aliases_positive/"
}
