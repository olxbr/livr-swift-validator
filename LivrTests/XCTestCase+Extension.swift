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
        var testResultJson: JSON?
        
        testResultJson = path.contains(String.negative) ? jsonLoader.load(file: .errors) : jsonLoader.load(file: .output)
        
        var validator = LIVR.validator(validationRules: rulesJson)
        
        var output: Validator.Output?
        do {
            output = try validator.validate(data: inputJson)
        } catch {
            XCTFail((error as? ValidatingError)?.description ?? error.localizedDescription)
            return
        }
        
        guard let expectedResultJson = testResultJson else { XCTFail(.nilTestResultJson); return }
        
        if path.contains(String.negative) {
            guard let errors = validator.errors else { XCTFail(.nilValidatorErrros); return }
            XCTAssertTrue(errors.isEqual(to: expectedResultJson), .validatorErrorsNotAsExpected)
        } else {
            guard let output = output else { XCTFail(.nilValidatorOutput); return }
            XCTAssertTrue(output.isEqual(to: expectedResultJson), .validatorOutputNotAsExpected)
        }
    }
}

// MARK: - Private constants
private extension String {
    static let negative = "negative"
    static let nilTestResultJson = "Test result json loaded from bundle should not be nil"
    static let nilValidatorErrros = "Validator errors should not be nil"
    static let nilValidatorOutput = "Validator output should not be nil"
    static let validatorErrorsNotAsExpected = "Validator errors should match test expectation"
    static let validatorOutputNotAsExpected = "Validator output should match test expectation"
}
