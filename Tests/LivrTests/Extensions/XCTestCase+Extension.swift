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
        
        guard let inputJson = jsonLoader.load(file: .input) as? [String: Any?] else { fatalError("nilInputJson") }
        guard let rulesJson = jsonLoader.load(file: .rules) as? [String: Any?] else { fatalError("nilRulesJson") }
        var testResultJson: [String: Any?]?
        
        if path.contains(String.negative), let errorJson = jsonLoader.load(file: .errors) as? [String: Any?] {
            testResultJson = errorJson
        } else if let outputJson = jsonLoader.load(file: .output) as? [String: Any?] {
            testResultJson = outputJson
        }
        
        var validator = LIVR.validator(validationRules: rulesJson)
        
        loadAliasesIfNeeded(for: path, validator: validator, jsonLoader: jsonLoader)
        
        var output: Validator.Output?
        do {
            output = try validator.validate(data: inputJson)
        } catch {
            XCTFail((error as? Validator.ErrorType)?.description ?? error.localizedDescription)
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
    
    private func loadAliasesIfNeeded(for path: String, validator: Validator, jsonLoader: JsonLoader) {
        guard path.contains(String.aliases) else { return }
        guard let aliases = jsonLoader.load(file: .aliases) as? [[String: Any?]] else {
            fatalError(.errorLoadingAliasesJson)
        }
        
        do {
            try validator.registerRule(aliases: aliases)
        } catch {
            fatalError((error as? Validator.ErrorType)?.description ?? error.localizedDescription)
        }
    }
}

// MARK: - Private constants
private extension String {
    static let negative = "negative"
    static let aliases = "aliases"
    static let nilTestResultJson = "Test result json loaded from bundle should not be nil"
    static let nilValidatorErrros = "Validator errors should not be nil"
    static let nilValidatorOutput = "Validator output should not be nil"
    static let validatorErrorsNotAsExpected = "Validator errors should match test expectation"
    static let validatorOutputNotAsExpected = "Validator output should match test expectation"
    static let errorLoadingAliasesJson = "Aliases json could not be loaded from bundle as [[String: Any?]]"
}
