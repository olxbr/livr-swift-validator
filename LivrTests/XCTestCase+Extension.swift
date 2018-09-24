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
    
    func validate(testSuiteAt path: String, appendToInput extraInputJson: JSON? = nil, appendToRules extraRulesJson: JSON? = nil) {
        let jsonLoader = JsonLoader(testDirectory: path)
        
        var inputJson = jsonLoader.load(file: .input)
        let outputJson = jsonLoader.load(file: .output)
        var rulesJson = jsonLoader.load(file: .rules)
        
        if let extraInputJson = extraInputJson {
            inputJson.merge(extraInputJson, uniquingKeysWith: { (current, _) in current })
        }
        if let extraRulesJson = extraRulesJson {
            rulesJson.merge(extraRulesJson, uniquingKeysWith: { (current, _) in current })
        }
        
        var validator = LIVR.validator(validationRules: rulesJson)
        
        var outputAndErrors: (Validator.Output?, Validator.Errors?)?
        do {
            outputAndErrors = try validator.validate(data: inputJson)
        } catch {
            XCTFail((error as? ValidatingError)?.description ?? error.localizedDescription)
        }
        
        XCTAssertNil(outputAndErrors?.1, "errors json should be nil")
        XCTAssertEqual(outputAndErrors?.0?.string(prettify: true), outputJson.string(prettify: true),"output json should be correct")
    }
}
