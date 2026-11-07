//
//  MetaRules.swift
//  Livr
//
//  Created by Felipe Lefèvre Marino on 9/29/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

import Foundation

protocol RuleThatCreatesValidator {
    var isAutoTrim: Bool {get set}
}

/// errors of a list rule start with null for each valid item before the first error
private func nullForEach(_ validItems: [Any]?) -> [Any] {
    return [Any](repeating: NSNull(), count: validItems?.count ?? 0)
}

/// the schema of nested_object and list_of_objects; arguments after it are ignored
private func objectSchema(_ arguments: Any?) -> [String: Any?]? {
    return arguments as? [String: Any?] ?? (arguments as? [Any])?.first as? [String: Any?]
}

/// the rules of variable_object and list_of_different_objects for each value of the key field
private func prepareRulesByKeyFieldValue(_ arguments: Any?) throws -> [String: [String: [LivrRule]]]? {
    guard let variableObjectRules = arguments as? [Any], variableObjectRules.count > 1,
        let validationForEachKeyFieldValue = variableObjectRules[1] as? [String: Any?] else { return nil }
    
    var rulesByKeyFieldValue: [String: [String: [LivrRule]]] = [:]
    for (keyFieldValue, validationRules) in validationForEachKeyFieldValue {
        if let validationRules = validationRules as? [String: Any?] {
            rulesByKeyFieldValue[keyFieldValue] = try Validator.rulesByField(from: validationRules)
        }
    }
    return rulesByKeyFieldValue
}

/// A reference to another field (LIVR 2.5): "name" or a path down from the containing object, "a/b/0"
struct FieldReference {
    private let segments: [String]
    
    init(_ reference: Any, of ruleName: String) throws {
        let wrongReference = Validator.ErrorType.wrongArguments(rule: ruleName, reason: "wrong field reference \(reference)")
        guard let reference = reference as? String, !reference.isEmpty,
            !reference.hasPrefix("/"), !reference.hasSuffix("/") else { throw wrongReference }
        
        segments = try reference.split(separator: "/", omittingEmptySubsequences: false).map { segment in
            guard !segment.isEmpty, let segment = FieldReference.unescaped(segment) else { throw wrongReference }
            return segment
        }
    }
    
    /// ~1 is "/" and ~0 is "~", as in JSON Pointer
    private static func unescaped(_ segment: Substring) -> String? {
        var result = ""
        var characters = segment.makeIterator()
        while let character = characters.next() {
            guard character == "~" else { result.append(character); continue }
            switch characters.next() {
            case "0"?: result.append("~")
            case "1"?: result.append("/")
            default: return nil
            }
        }
        return result
    }
    
    /// the input value of the referenced field (trimmed with the automatic trim), nil when it is missing
    func value(in object: [String: Any?]?, isAutoTrim: Bool) -> Any? {
        var value: Any? = object
        for segment in segments {
            if let object = value as? [String: Any?] {
                value = object[segment] ?? nil
            } else if let list = value as? [Any], segment == "0" || (Utils.isDigits(segment) && !segment.hasPrefix("0")),
                let index = Int(segment), index < list.count {
                value = list[index]
            } else {
                return nil
            }
        }
        if isAutoTrim, let string = value as? String {
            return string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return value
    }
}

struct MetaRules {
    
    struct NestedObject: LivrRule, PreDefinedRule, RuleThatCreatesValidator {
        static var name: String = "nested_object"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        var updatedValue: UpdatedValue?
        var isAutoTrim: Bool = true
        private var rulesByField: [String: [LivrRule]]?
        
        mutating func prepare() throws {
            guard let validationRules = objectSchema(arguments) else { return }
            rulesByField = try Validator.rulesByField(from: validationRules)
        }
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            guard let rulesByField = rulesByField else { return (errorCode.rawValue, nil) }
            if Utils.hasNoValue(value) { return (nil, nil) }
            
            if !(value is [String: Any?]) { return (errorCode.rawValue, nil) }
            
            let validator = Validator(rulesByField: rulesByField, isAutoTrim: isAutoTrim)
            
            var output: [String: Any?]?
            do {
                output = try validator.validate(data: value as! [String: Any?])
            } catch {
                return (errorCode.rawValue, nil)
            }
            
            if let output = output {
                return (nil, output as AnyObject)
            }
            return (validator.errors, nil)
        }
    }
    
    struct VariableObject: LivrRule, PreDefinedRule, RuleThatCreatesValidator {
        static var name: String = "variable_object"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        var updatedValue: UpdatedValue?
        var isAutoTrim: Bool = true
        private var rulesByKeyFieldValue: [String: [String: [LivrRule]]]?
        
        mutating func prepare() throws {
            rulesByKeyFieldValue = try prepareRulesByKeyFieldValue(arguments)
        }
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            guard let rulesByKeyFieldValue = rulesByKeyFieldValue else { return (errorCode.rawValue, nil) }
            if Utils.hasNoValue(value) { return (nil, nil) }
            
            if !(value is [String: Any?]) { return (errorCode.rawValue, nil) }
            
            guard let keyField = (arguments as? [Any])?.first as? String,
                let valueAsJson = value as? [String: Any?],
                let keyFieldValue = valueAsJson[keyField] as? String,
                let rulesByField = rulesByKeyFieldValue[keyFieldValue] else {
                    
                return (errorCode.rawValue, nil)
            }
                
            let validator = Validator(rulesByField: rulesByField, isAutoTrim: isAutoTrim)
            
            var output: [String: Any?]?
            do {
                output = try validator.validate(data: valueAsJson)
            } catch {
                return (errorCode.rawValue, nil)
            }
            
            if let output = output {
                return (nil, output as AnyObject)
            }
            return (validator.errors, nil)
        }
    }
    
    struct ListOf: LivrRule, PreDefinedRule, RuleThatCreatesValidator {
        static var name: String = "list_of"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        var updatedValue: UpdatedValue?
        var isAutoTrim: Bool = true
        private var rules: [LivrRule]?
        
        mutating func prepare() throws {
            rules = try RuleGenerator.generateRules(from: arguments)
        }
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            
            if let value = value {
                // items can be lists too: { "list_of": { "list_length": 2 } }
                if !Utils.isList(value) { return (errorCode.rawValue, nil) }
                
                var errors: [Any]?
                var output: [Any]?
                
                let validator = LIVR.validator(isAutoTrim: isAutoTrim)
                
                if let listOfValues = value as? [Any] {
                    for value in listOfValues {
                        
                        // items have no containing object: rules that read other fields see no fields
                        let errorAndUpdatedValue = rules.map { validator.validate(value: value, fieldRules: $0) } ?? (nil, nil)
                        if let error = errorAndUpdatedValue.0 {
                            errors == nil ? errors = nullForEach(output) : ()
                            errors?.append(error as Any)
                        } else if errors != nil {
                            errors?.append(NSNull())
                        } else if errors == nil {
                            output == nil ? output = [] : ()
                            output?.append(errorAndUpdatedValue.1 ?? value)
                        }
                    }
                    
                    if errors != nil {
                        return (errors, nil)
                    }
                    return (nil, (output ?? value) as AnyObject)
                }
            }
            
            return (nil, nil)
        }
    }
    
    struct ListOfObjects: LivrRule, PreDefinedRule, RuleThatCreatesValidator {
        static var name: String = "list_of_objects"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        var updatedValue: UpdatedValue?
        var isAutoTrim: Bool = true
        private var rulesByField: [String: [LivrRule]]?
        
        mutating func prepare() throws {
            guard let validationRules = objectSchema(arguments) else { return }
            rulesByField = try Validator.rulesByField(from: validationRules)
        }
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            
            if let value = value {
                if !Utils.isList(value) { return (errorCode.rawValue, nil) }
                guard value as? [[Any]] == nil || (value as? [Any])?.count == 0 else { return (errorCode.rawValue, nil) }
                guard let rulesByField = rulesByField else { return (errorCode.rawValue, nil) }

                var errors: [Any]?
                var output: [Any]?
                
                if let listOfValues = value as? [Any] {
                    for value in listOfValues {
                        
                        guard let object = value as? [String: Any?] else {
                            errors == nil ? errors = nullForEach(output) : ()
                            errors?.append(errorCode.rawValue)
                            continue
                        }
                        
                        let validator = Validator(rulesByField: rulesByField, isAutoTrim: isAutoTrim)
                        
                        var validatorOutput: [String: Any?]?
                        do {
                            validatorOutput = try validator.validate(data: object)
                        } catch {
                            return (errorCode.rawValue, nil)
                        }
                        
                        if let validationErrors = validator.errors {
                            errors == nil ? errors = nullForEach(output) : ()
                            errors?.append(validationErrors as Any)
                        } else if errors != nil {
                            errors?.append(NSNull())
                        } else if errors == nil {
                            output == nil ? output = [] : ()
                            output?.append(validatorOutput as Any)
                        }
                    }
                    
                    if errors != nil {
                        return (errors, nil)
                    }
                    return (nil, (output ?? value) as AnyObject)
                }
            }
            
            return (nil, nil)
        }
    }
    
    struct ListOfDifferentObjects: LivrRule, PreDefinedRule, RuleThatCreatesValidator {
        static var name: String = "list_of_different_objects"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        var updatedValue: UpdatedValue?
        var isAutoTrim: Bool = true
        private var rulesByKeyFieldValue: [String: [String: [LivrRule]]]?
        
        mutating func prepare() throws {
            rulesByKeyFieldValue = try prepareRulesByKeyFieldValue(arguments)
        }
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            
            if let value = value {
                if !Utils.isList(value) { return (errorCode.rawValue, nil) }
                guard value as? [[Any]] == nil || (value as? [Any])?.count == 0 else { return (errorCode.rawValue, nil) }
                guard let rulesByKeyFieldValue = rulesByKeyFieldValue,
                    let keyField = (arguments as? [Any])?.first as? String else { return (errorCode.rawValue, nil) }
                
                var errors: [Any]?
                var output: [Any]?
                
                if let listOfValues = value as? [Any] {
                    for value in listOfValues {
                        
                        guard let valueAsJson = value as? [String: Any?],
                            let keyFieldValue = valueAsJson[keyField] as? String,
                            let rulesByField = rulesByKeyFieldValue[keyFieldValue] else {
                                
                                errors == nil ? errors = nullForEach(output) : ()
                                errors?.append(errorCode.rawValue)
                                continue
                        }
                        
                        let validator = Validator(rulesByField: rulesByField, isAutoTrim: isAutoTrim)
                        
                        var validatorOutput: [String: Any?]?
                        do {
                            validatorOutput = try validator.validate(data: valueAsJson)
                        } catch {
                            return (errorCode.rawValue, nil)
                        }
                        
                        if let validationErrors = validator.errors {
                            errors == nil ? errors = nullForEach(output) : ()
                            errors?.append(validationErrors as Any)
                        } else if errors != nil {
                            errors?.append(NSNull())
                        } else if errors == nil {
                            output == nil ? output = [] : ()
                            output?.append(validatorOutput as Any)
                        }
                    }
                    
                    if errors != nil {
                        return (errors, nil)
                    }
                    return (nil, (output ?? value) as AnyObject)
                }
            }
            
            return (nil, nil)
        }
    }
    
    struct Or: LivrRule, PreDefinedRule, RuleThatCreatesValidator {
        static var name: String = "or"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        var updatedValue: UpdatedValue?
        var isAutoTrim: Bool = true
        private var setsOfRules: [[LivrRule]] = []
        
        mutating func prepare() throws {
            guard let arrayOfArguments = arguments as? [Any] else { return }
            setsOfRules = try arrayOfArguments.compactMap { try RuleGenerator.generateRules(from: $0) }
        }
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            return validate(value: value, in: nil)
        }
        
        /// the rules of each branch see the object that contains the field
        func validate(value: Any?, in object: [String: Any?]?) -> (Errors?, UpdatedValue?) {
            // applies each set of rules until one succeeds, otherwise returns the error of the last one
            var lastError: LivrRule.Errors?
            let validator = LIVR.validator(isAutoTrim: isAutoTrim)
            
            for rules in setsOfRules {
                let errorAndUpdatedValue = validator.validate(value: value, rules: rules, in: object)
                
                if let error = errorAndUpdatedValue.0 {
                    lastError = error
                } else {
                    return (nil, errorAndUpdatedValue.1)
                }
            }
            return (lastError, nil)
        }
    }
    
    // MARK: - LIVR 2.5
    
    /// { "when": [REFERENCE, CONDITION, RULES_IF_TRUE, RULES_IF_FALSE] } or { "when": [REFERENCE, CASES] }
    struct When: LivrRule, PreDefinedRule, RuleThatCreatesValidator {
        static var name: String = "when"
        var errorCode: LIVR.ErrorCode = .notAllowedValue
        var arguments: Any?
        var isAutoTrim: Bool = true
        private var reference: FieldReference?
        /// nil in the switch form
        private var condition: [LivrRule]?
        private var rulesIfTrue: [LivrRule] = []
        private var rulesIfFalse: [LivrRule]?
        private var cases: [ExactString: [LivrRule]] = [:]
        
        mutating func prepare() throws {
            let arguments = Utils.argumentsList(self.arguments)
            guard arguments.count >= 2 else {
                throw Validator.ErrorType.wrongArguments(rule: When.name, reason: "needs a reference and rules")
            }
            reference = try FieldReference(arguments[0], of: When.name)
            
            if arguments.count == 2 {
                guard let cases = arguments[1] as? [String: Any?], !cases.isEmpty else {
                    throw Validator.ErrorType.wrongArguments(rule: When.name, reason: "the cases must be a non-empty object")
                }
                for (key, rules) in cases {
                    self.cases[ExactString(key)] = try RuleGenerator.nonEmptyRules(from: rules, of: When.name)
                }
            } else {
                condition = try RuleGenerator.nonEmptyRules(from: arguments[1], of: When.name)
                rulesIfTrue = try RuleGenerator.nonEmptyRules(from: arguments[2], of: When.name)
                if arguments.count > 3 {
                    rulesIfFalse = try RuleGenerator.nonEmptyRules(from: arguments[3], of: When.name)
                }
            }
        }
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            return validate(value: value, in: nil)
        }
        
        /// the condition checks the referenced value; all the rules see the object that contains the field
        func validate(value: Any?, in object: [String: Any?]?) -> (Errors?, UpdatedValue?) {
            guard let reference = reference else { return (nil, nil) }
            let referencedValue = reference.value(in: object, isAutoTrim: isAutoTrim)
            let validator = LIVR.validator(isAutoTrim: isAutoTrim)
            
            var rules: [LivrRule]?
            if let condition = condition {
                let isTrue = !Utils.hasNoValue(referencedValue)
                    && validator.validate(value: referencedValue, rules: condition, in: object).0 == nil
                rules = isTrue ? rulesIfTrue : rulesIfFalse
            } else {
                // no case for an empty, unknown or non-primitive referenced value
                let key = Utils.hasNoValue(referencedValue) ? nil : Utils.stringForm(referencedValue)
                guard let caseRules = key.flatMap({ cases[ExactString($0)] }) else {
                    return Utils.hasNoValue(value) ? (nil, nil) : (errorCode.rawValue, nil)
                }
                rules = caseRules
            }
            
            guard let branch = rules else { return (nil, nil) }
            let errorAndUpdatedValue = validator.validate(value: value, rules: branch, in: object)
            if let error = errorAndUpdatedValue.0 {
                return (error, nil)
            }
            return (nil, errorAndUpdatedValue.1)
        }
    }
    
    /// every value of an object is validated with the rules, as list_of validates every item
    struct Values: LivrRule, PreDefinedRule, RuleThatCreatesValidator {
        static var name: String = "values"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        var isAutoTrim: Bool = true
        private var rules: [LivrRule] = []
        
        mutating func prepare() throws {
            rules = try RuleGenerator.nonEmptyRules(from: arguments, of: Values.name)
        }
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            guard let object = value as? [String: Any?] else { return (errorCode.rawValue, nil) }
            
            let validator = LIVR.validator(isAutoTrim: isAutoTrim)
            var errors: [String: Any] = [:]
            var output: [String: Any] = [:]
            for (key, value) in object {
                let item: Any = value ?? NSNull()
                // values have no containing object: rules that read other fields see no fields
                let errorAndUpdatedValue = validator.validate(value: item, fieldRules: rules)
                if let error = errorAndUpdatedValue.0 {
                    errors[key] = error as Any
                } else {
                    output[key] = errorAndUpdatedValue.1 ?? item
                }
            }
            return errors.isEmpty ? (nil, output as AnyObject) : (errors, nil)
        }
    }
    
    /// every key of an object is validated as a string with the rules; the keys do not change
    struct Keys: LivrRule, PreDefinedRule, RuleThatCreatesValidator {
        static var name: String = "keys"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        var isAutoTrim: Bool = true
        private var rules: [LivrRule] = []
        
        mutating func prepare() throws {
            rules = try RuleGenerator.nonEmptyRules(from: arguments, of: Keys.name)
        }
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            guard let object = value as? [String: Any?] else { return (errorCode.rawValue, nil) }
            
            // the automatic trim trims values, not keys
            let validator = LIVR.validator(isAutoTrim: isAutoTrim)
            var errors: [String: Any] = [:]
            for key in object.keys where validator.validate(value: key, rules: rules).0 != nil {
                errors[key] = LIVR.ErrorCode.wrongKey.rawValue
            }
            return errors.isEmpty ? (nil, nil) : (errors, nil)
        }
    }
    
    /// any JSON value passes unchanged
    struct AnyValue: LivrRule, PreDefinedRule {
        static var name: String = "any"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        
        mutating func prepare() throws {
            try RuleGenerator.checkNoArguments(arguments, of: AnyValue.name)
        }
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            return (nil, nil)
        }
    }
}
