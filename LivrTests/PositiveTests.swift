//
//  LivrTests.swift
//  LivrTests
//
//  Created by Felipe Lefèvre Marino on 9/20/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

import XCTest
@testable import Livr

class PositiveTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRequired() {
        let jsonLoader = JsonLoader(testDirectory: .resourcesPath + "01-required")
        
        let inputJson = jsonLoader.load(file: .input)
        let outputJson = jsonLoader.load(file: .output)
        let rulesJson = jsonLoader.load(file: .rules)
        
        var validator = LIVR.validator(validationRules: rulesJson)
        let outputAndErrors = validator.validate(data: inputJson)
        
        XCTAssertNil(outputAndErrors.1, "errors json should be nil")
        XCTAssertEqual(outputAndErrors.0?.description, outputJson.description,"output json should be correct")
    }
    
    func testNotEmpty() {
        let jsonLoader = JsonLoader(testDirectory: .resourcesPath + "02-not_empty")
        
        let inputJson = jsonLoader.load(file: .input)
        let outputJson = jsonLoader.load(file: .output)
        let rulesJson = jsonLoader.load(file: .rules)
        
        var validator = LIVR.validator(validationRules: rulesJson)
        let outputAndErrors = validator.validate(data: inputJson)
        
        XCTAssertNil(outputAndErrors.1, "errors json should be nil")
        XCTAssertEqual(outputAndErrors.0?.description, outputJson.description,"output json should be correct")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
}

// MARK: - Private Constants
private extension String {
    static let resourcesPath = "resources/positive/"
}
