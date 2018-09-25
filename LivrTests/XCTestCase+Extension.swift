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
        let rulesJson = jsonLoader.load(file: .rules)
        var resultsJson: JSON?
        
        resultsJson = path.contains(String.negative) ? jsonLoader.load(file: .errors) : jsonLoader.load(file: .output)
        
        var validator = LIVR.validator(validationRules: rulesJson)
        
        var outputOrErrors: Validator.OutputOrErrors?
        do {
            outputOrErrors = try validator.validate(data: inputJson)
        } catch {
            XCTFail((error as? ValidatingError)?.description ?? error.localizedDescription)
        }
        
        guard let suiteResultsJson = resultsJson, let validationOutputOrErrors = outputOrErrors else {
            XCTFail(.nilSuiteOrValidationJson)
            return
        }
        XCTAssertTrue((validationOutputOrErrors.isEqual(to: suiteResultsJson)), .validationResultError)
    }
}

// MARK: - Private constants
private extension String {
    static let validationResultError = "validator validation result json should be equal to output or errros json for current test suite"
    static let nilSuiteOrValidationJson = "Suite json loaded from bundle or validation result should not be nil"
    static let negative = "negative"
}
