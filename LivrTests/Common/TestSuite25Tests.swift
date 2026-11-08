//
//  TestSuite25Tests.swift
//  LivrTests
//
//  Runs the LIVR 2.5 test suite (resources/test_suite_2.5): every case directory of each suite.
//

import XCTest
@testable import Livr

class TestSuite25Tests: XCTestCase {
    
    func testPositive() {
        runCases(in: "positive")
    }
    
    func testNegative() {
        runCases(in: "negative")
    }
    
    func testAliasesPositive() {
        runCases(in: "aliases_positive")
    }
    
    func testAliasesNegative() {
        runCases(in: "aliases_negative")
    }
    
    /// schemas that must not build: preparing the validator, with the aliases registered, throws
    func testSchemaErrors() {
        for caseDirectory in caseDirectories(in: "schema_errors") {
            let registeredRules = LIVR.defaultRules
            defer { LIVR.defaultRules = registeredRules }
            
            guard let rules = json(caseDirectory, "rules") as? [String: Any?] else {
                XCTFail(caseDirectory.lastPathComponent + ": could not load rules.json")
                continue
            }
            let validator = LIVR.validator(validationRules: rules, isAutoTrim: false)
            if let aliases = json(caseDirectory, "aliases") as? [[String: Any?]] {
                XCTAssertNoThrow(try validator.registerRule(aliases: aliases), caseDirectory.lastPathComponent)
            }
            XCTAssertThrowsError(try validator.prepare(), caseDirectory.lastPathComponent)
        }
    }
    
    // MARK: - LIVR 2.5 features that the test suite does not show
    
    func testStringFormOfNumbers() {
        let vectors: [(Any, String)] = [(1.0, "1"), (-0.0, "0"), (100, "100"), (1e3, "1000"), (0.1, "0.1"),
                                        (-12.25, "-12.25"), (123456789012345, "123456789012345"),
                                        (0.000001, "0.000001"), (1.5e-6, "0.0000015"), (true, "true"), (false, "false")]
        for (number, stringForm) in vectors {
            XCTAssertEqual(Utils.stringForm(number), stringForm)
            let fromJSON = try? JSONSerialization.jsonObject(with: "[\(stringForm)]".data(using: .utf8)!) as? [Any]
            XCTAssertEqual(Utils.stringForm(fromJSON??.first), stringForm)
        }
        XCTAssertFalse(Utils.isBoolean(1))
        XCTAssertFalse(Utils.isBoolean(0))
        XCTAssertTrue(Utils.isBoolean(true))
    }
    
    func testCurrentDateIsTheSystemTimeInUTC() {
        let validator = LIVR.validator(validationRules: ["date": ["iso_date": ["min": "today", "max": "today"]]])
        let today = DateFormatter()
        today.dateFormat = "yyyy-MM-dd"
        today.locale = Locale(identifier: "en_US_POSIX")
        today.timeZone = TimeZone(identifier: "UTC")
        let output = try? validator.validate(data: ["date": today.string(from: Date())])
        XCTAssertNil(validator.errors)
        XCTAssertNotNil(output as Any?)
    }
    
    func testReferencesSeeTheTrimmedInputWithAutoTrim() {
        let rules: [String: Any?] = ["address": ["nested_object": ["country": "required"]],
                                     "zip": ["required_if": ["address/country": "UA"]],
                                     "vat": ["when": ["type", ["eq": "company"], "required"]]]
        let validator = LIVR.validator(validationRules: rules, isAutoTrim: true)
        _ = try? validator.validate(data: ["address": ["country": " UA "], "type": " company "])
        let expectedErrors: [String: Any] = ["zip": "REQUIRED", "vat": "REQUIRED"]
        XCTAssertTrue((validator.errors ?? [:]).isEqual(to: expectedErrors), "\(String(describing: validator.errors))")
    }
    
    func testMetaRulesIgnoreExtraArguments() {
        let rules: [String: Any?] = ["object": ["nested_object": [["age": "adult_age"], "extra"]],
                                     "objects": ["list_of_objects": [["age": "adult_age"], "extra"]]]
        let validator = LIVR.validator(validationRules: rules)
        validator.register(customRule: AdultAge())
        let output = try? validator.validate(data: ["object": ["age": "20", "x": 1], "objects": [["age": "30"]]])
        XCTAssertNil(validator.errors)
        let expectedOutput: [String: Any] = ["object": ["age": "20"], "objects": [["age": "30"]]]
        XCTAssertTrue((output ?? nil)?.isEqual(to: expectedOutput) == true, "\(String(describing: output))")
        
        _ = try? validator.validate(data: ["object": ["age": "10"], "objects": [["age": "30"], ["age": "10"]]])
        let expectedErrors: [String: Any] = ["object": ["age": "FORMAT_ERROR"], "objects": [NSNull(), ["age": "FORMAT_ERROR"]]]
        XCTAssertTrue((validator.errors ?? [:]).isEqual(to: expectedErrors), "\(String(describing: validator.errors))")
    }
    
    /// an unknown rule is a schema error of prepare() and validate(data:), also in a list or a nested schema
    func testUnknownRuleIsASchemaError() {
        let registeredRules = LIVR.defaultRules
        defer { LIVR.defaultRules = registeredRules }
        let schemas: [[String: Any?]] = [["unknown": "no_such_rule"],
                                         ["unknown_in_list": ["required", "no_such_rule", ["max_length": 3]]],
                                         ["unknown_with_arguments": ["no_such_rule": 1]],
                                         ["nested": ["nested_object": ["inner": ["no_such_rule", "required"]]]],
                                         ["alias": "alias_with_unknown_rule"]]
        for rules in schemas {
            let validator = LIVR.validator(validationRules: rules, isAutoTrim: false)
            validator.registerRule(alias: "alias_with_unknown_rule", rules: ["required", "no_such_rule"])
            XCTAssertThrowsError(try validator.prepare(), "\(rules)") { error in
                guard case .notRegistered(let rule)? = error as? Validator.ErrorType else {
                    return XCTFail("\(rules): \(error)")
                }
                XCTAssertEqual(rule, "no_such_rule")
            }
            XCTAssertThrowsError(try validator.validate(data: ["unknown": "x", "unknown_in_list": "abc"]), "\(rules)")
            XCTAssertNil(validator.errors, "\(rules)")
            // and stays one: the second validation throws too
            XCTAssertThrowsError(try validator.validate(data: [:]), "\(rules)")
        }
        
        // validate(value:validationRules:) does not throw: a schema error gives no errors and no value
        let validator = LIVR.validator(validationRules: [:])
        let result = validator.validate(value: "abcd", validationRules: ["no_such_rule", ["max_length": 3]])
        XCTAssertNil(result.0)
        XCTAssertNil(result.1)
        
        // wrong arguments of a known rule are a schema error of both
        let wrongArguments = LIVR.validator(validationRules: ["field": ["list_length": "x"]])
        XCTAssertThrowsError(try wrongArguments.prepare())
        XCTAssertThrowsError(try wrongArguments.validate(data: [:]))
    }
    
    /// {"eq": true} accepts true and "true" (LIVR 2.5), and "1", as LIVR 2.0 compared booleans
    func testEqAndOneOfWithBooleans() {
        let rules: [String: Any?] = ["eq": ["eq": true], "eq_false": ["eq": false], "one_of": ["one_of": [true, "x"]],
                                     "eq_string": ["eq": "true"], "eq_one": ["eq": "1"], "one_of_one": ["one_of": ["1", "x"]]]
        let validator = LIVR.validator(validationRules: rules, isAutoTrim: false)
        for (field, values) in [("eq", [true, "true", "1", 1]), ("eq_false", [false, "false", "0", 0]), ("one_of", [true, "true", "1"]),
                                ("eq_string", [true]), ("eq_one", [true]), ("one_of_one", [true])] as [(String, [Any])] {
            for value in values {
                let jsonValue = jsonObject("[\(value is String ? "\"\(value)\"" : Utils.stringForm(value)!)]")
                for value in [value, jsonValue] {
                    _ = try? validator.validate(data: [field: value])
                    XCTAssertNil(validator.errors, "\(field): \(value)")
                }
            }
        }
        for (field, value) in [("eq", "yes"), ("eq", "True"), ("eq", "2"), ("eq_false", "true"), ("eq_false", "1"), ("one_of", "false")] {
            _ = try? validator.validate(data: [field: value])
            XCTAssertTrue((validator.errors ?? [:]).isEqual(to: [field: "NOT_ALLOWED_VALUE"]), "\(field): \(value)")
        }
    }
    
    /// {"rule": null} is one null argument: a schema error for the LIVR 2.5 rules; iso_date, the 2.0 rules and
    /// custom rules keep their 2.0 handling. A Swift nil is null too (JSON null becomes nil on Apple platforms).
    func testNullIsOneArgument() {
        XCTAssertNoThrow(try LIVR.validator(validationRules: ["a": "boolean", "b": ["iso_date": NSNull()],
                                                              "c": ["iso_date": [NSNull()]], "d": ["iso_date": nil]]).prepare())
        XCTAssertThrowsError(try LIVR.validator(validationRules: ["field": ["boolean": nil]]).prepare())
        XCTAssertThrowsError(try LIVR.validator(validationRules: ["field": [["uuid": nil]]]).prepare())
        for rules in [["boolean": NSNull()], ["boolean": [NSNull()]], ["uuid": NSNull()], ["unique": NSNull()],
                      ["iso_time": NSNull()], ["iso_datetime": NSNull()], ["not_one_of": NSNull()], ["not_one_of": [NSNull()]],
                      ["split": NSNull()], ["list_length": NSNull()], ["list_length": ["min": NSNull()]],
                      ["required_if": ["type": NSNull()]], ["values": NSNull()], ["when": NSNull()]] as [[String: Any]] {
            XCTAssertThrowsError(try LIVR.validator(validationRules: ["field": rules]).prepare(), "\(rules)")
        }
        
        let validator = LIVR.validator(validationRules: ["field": ["default": NSNull()], "custom": ["arguments_of_rule": NSNull()]], isAutoTrim: false)
        validator.register(customRule: ArgumentsOfRule())
        let output = try? validator.validate(data: ["custom": "x"])
        XCTAssertNil(validator.errors)
        XCTAssertTrue((output ?? nil)?["field"].map { $0 is NSNull } == true, "\(String(describing: output))")
        XCTAssertTrue((output ?? nil)?["custom"].map { $0 is NSNull } == true, "\(String(describing: output))")
        
        // a custom rule registered with the name of a LIVR 2.5 rule gets its arguments as they are
        let registeredRules = LIVR.defaultRules
        defer { LIVR.defaultRules = registeredRules }
        var customBoolean = ArgumentsOfRule()
        customBoolean.name = "boolean"
        let overridden = LIVR.validator(validationRules: ["field": ["boolean": nil]], isAutoTrim: false)
        overridden.register(customRule: customBoolean)
        let overriddenOutput = try? overridden.validate(data: ["field": "x"])
        XCTAssertEqual(((overriddenOutput ?? nil)?["field"] ?? nil) as? String, "nil")
    }
    
    /// strings are compared code point by code point: a precomposed letter is not the letter with a combining mark
    func testStringsAreComparedWithoutNormalization() {
        let precomposed = "caf\u{E9}", decomposed = "cafe\u{301}"
        XCTAssertTrue(precomposed == decomposed, "Swift compares canonical equivalence")
        let rules: [String: Any?] = ["eq": ["eq": precomposed], "one_of": ["one_of": [precomposed]],
                                     "not_one_of": ["not_one_of": [precomposed]], "unique": "unique",
                                     "required_if": ["required_if": ["type": precomposed]],
                                     "when": ["when": ["type", [precomposed: "required"]]]]
        let validator = LIVR.validator(validationRules: rules, isAutoTrim: false)
        _ = try? validator.validate(data: ["eq": decomposed, "one_of": decomposed, "not_one_of": decomposed,
                                           "unique": [precomposed, decomposed], "type": decomposed, "when": "x"])
        let expectedErrors: [String: Any] = ["eq": "NOT_ALLOWED_VALUE", "one_of": "NOT_ALLOWED_VALUE", "when": "NOT_ALLOWED_VALUE"]
        XCTAssertTrue((validator.errors ?? [:]).isEqual(to: expectedErrors), "\(String(describing: validator.errors))")
        
        _ = try? validator.validate(data: ["eq": precomposed, "one_of": precomposed, "not_one_of": precomposed,
                                           "unique": [precomposed, precomposed], "type": precomposed])
        let expectedErrorsForTheSameStrings: [String: Any] = ["not_one_of": "NOT_ALLOWED_VALUE", "unique": "NOT_UNIQUE_ITEMS",
                                                             "required_if": "REQUIRED", "when": "REQUIRED"]
        XCTAssertTrue((validator.errors ?? [:]).isEqual(to: expectedErrorsForTheSameStrings), "\(String(describing: validator.errors))")
    }
    
    private func jsonObject(_ json: String) -> Any {
        return (try! JSONSerialization.jsonObject(with: json.data(using: .utf8)!) as! [Any])[0]
    }
}

/// a custom rule that outputs its arguments
private struct ArgumentsOfRule: CustomRule {
    var name: String = "arguments_of_rule"
    var rules: Any?
    var arguments: Any?
    var errorCode: LIVR.ErrorCode = .format
    var customErrorCode: String?
    
    func validate(value: Any?) -> (Errors?, UpdatedValue?) {
        return (nil, arguments.map { $0 as AnyObject } ?? ("nil" as AnyObject))
    }
}

// MARK: - Running the cases

private extension TestSuite25Tests {
    
    func caseDirectories(in suite: String) -> [URL] {
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle(for: TestSuite25Tests.self)
        #endif
        guard let suiteDirectory = bundle.url(forResource: suite, withExtension: nil, subdirectory: "resources/test_suite_2.5"),
            let names = try? FileManager.default.contentsOfDirectory(atPath: suiteDirectory.path) else {
            XCTFail("could not find the suite " + suite)
            return []
        }
        let directories = names.sorted().map { suiteDirectory.appendingPathComponent($0) }
        let caseDirectories = directories.filter { (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true }
        XCTAssertFalse(caseDirectories.isEmpty, "no cases in the suite " + suite)
        return caseDirectories
    }
    
    func json(_ caseDirectory: URL, _ name: String) -> Any? {
        guard let data = try? Data(contentsOf: caseDirectory.appendingPathComponent(name + ".json")) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }
    
    func runCases(in suite: String) {
        let isPositive = suite.hasSuffix("positive")
        for caseDirectory in caseDirectories(in: suite) {
            // aliases are registered for all validators: each case starts with the standard rules
            let registeredRules = LIVR.defaultRules
            let now = LIVR.now
            defer {
                LIVR.defaultRules = registeredRules
                LIVR.now = now
            }
            do {
                let name = suite + "/" + caseDirectory.lastPathComponent
                guard let rules = json(caseDirectory, "rules") as? [String: Any?],
                    let input = json(caseDirectory, "input") as? [String: Any?],
                    let expected = json(caseDirectory, isPositive ? "output" : "errors") else {
                    XCTFail(name + ": could not load the case files")
                    continue
                }
                // the current time of the case for today, yesterday and tomorrow
                if let options = json(caseDirectory, "options") as? [String: Any], let now = options["now"] as? String {
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: "en_US_POSIX")
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
                    guard let date = formatter.date(from: now) else {
                        XCTFail(name + ": wrong options.json")
                        continue
                    }
                    LIVR.now = { date }
                }
                
                // the test suite is written for validators without automatic trim
                let validator = LIVR.validator(validationRules: rules, isAutoTrim: false)
                do {
                    if let aliases = json(caseDirectory, "aliases") as? [[String: Any?]] {
                        try validator.registerRule(aliases: aliases)
                    }
                    let output = try validator.validate(data: input)
                    if isPositive {
                        XCTAssertNil(validator.errors, name + ": \(String(describing: validator.errors))")
                        XCTAssertTrue(isSameJSON(output, expected), name + ": output differs in " + differences(output, expected))
                    } else {
                        XCTAssertNil(output, name)
                        XCTAssertTrue(isSameJSON(validator.errors, expected), name + ": errors differ in " + differences(validator.errors, expected))
                    }
                } catch {
                    XCTFail(name + ": " + ((error as? Validator.ErrorType)?.description ?? "\(error)"))
                }
            }
        }
    }
}

/// JSON equality that tells booleans from numbers; numbers are compared by value, key order does not matter
private func isSameJSON(_ first: Any?, _ second: Any?) -> Bool {
    let first = unwrapped(first), second = unwrapped(second)
    if first == nil || first is NSNull || second == nil || second is NSNull {
        return (first == nil || first is NSNull) && (second == nil || second is NSNull)
    }
    if let first = first as? String, let second = second as? String { return first == second }
    if first is String || second is String { return false }
    if let first = first as? [String: Any?], let second = second as? [String: Any?] {
        return first.count == second.count && first.allSatisfy { key, value in
            second.keys.contains(key) && isSameJSON(value, second[key] ?? nil)
        }
    }
    if let first = first as? [Any], let second = second as? [Any] {
        return first.count == second.count && zip(first, second).allSatisfy { isSameJSON($0, $1) }
    }
    if let first = first as? NSNumber, let second = second as? NSNumber {
        if Utils.isBoolean(first) || Utils.isBoolean(second) {
            return Utils.isBoolean(first) && Utils.isBoolean(second) && first.boolValue == second.boolValue
        }
        return first.doubleValue == second.doubleValue
    }
    return false
}

/// the keys whose values differ, with both values
private func differences(_ actual: Any?, _ expected: Any) -> String {
    guard let actualObject = unwrapped(actual) as? [String: Any?], let expectedObject = expected as? [String: Any?] else {
        return "\(String(describing: unwrapped(actual))) instead of \(expected)"
    }
    let keys = Set(actualObject.keys).union(expectedObject.keys).filter {
        !isSameJSON(actualObject[$0] ?? nil, expectedObject[$0] ?? nil)
    }
    return keys.sorted().map { key in
        let actualValue = String(describing: unwrapped(actualObject[key] ?? nil))
        let expectedValue = String(describing: unwrapped(expectedObject[key] ?? nil))
        return key + ": " + actualValue + " instead of " + expectedValue
    }.joined(separator: "; ")
}

private func unwrapped(_ value: Any?) -> Any? {
    guard let value = value else { return nil }
    let mirror = Mirror(reflecting: value)
    if mirror.displayStyle == .optional {
        return mirror.children.first.flatMap { unwrapped($0.value) }
    }
    return value
}
