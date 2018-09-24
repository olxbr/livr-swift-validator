//
//  XCTestCase+Extension.swift
//  LivrTests
//
//  Created by Felipe Lefèvre Marino on 9/23/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

import XCTest
@testable import Livr

extension XCTestCase {
    
    func validate(testSuiteAt path: String) {
        let jsonLoader = JsonLoader(testDirectory: path)
        
        let inputJson = jsonLoader.load(file: .input)
        let outputJson = jsonLoader.load(file: .output)
        let rulesJson = jsonLoader.load(file: .rules)
        
        var validator = LIVR.validator(validationRules: rulesJson)
        let outputAndErrors = validator.validate(data: inputJson)
        
        XCTAssertNil(outputAndErrors.1, "errors json should be nil")
        XCTAssertEqual(outputAndErrors.0?.string(prettify: true), outputJson.string(prettify: true),"output json should be correct")
    }
}
