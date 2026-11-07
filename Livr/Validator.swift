//
//  Validator.swift
//  Pods-Livr
//
//  Created by Felipe Lefèvre Marino on 9/14/18.
//

import Foundation

public final class Validator {
    
    /// Private queue used to apply thread safety
    private var queue: DispatchQueue = DispatchQueue(label: "livr.validator.reader-writer.queue", attributes: .concurrent)
    
    /// Private error property - holds the dictionary of validation errors by field
    private var privateErrors: [String: Any?]?
    
    /// public error property - applies thread safety to the errors dictionary
    public private(set) var errors: [String: Any?]? {
        get {
            var errors: [String: Any?]? = nil
            queue.sync {
                errors = privateErrors
            }
            
            return errors
        }
        set {
            queue.async(flags: .barrier) {
                self.privateErrors = newValue
            }
        }
    }
    
    /// Private output property - holds the dictionary of outputs
    private var privateOutput: [String: Any?]?
    
    /// public output property - applies thread safety to the output dictionary
    public private(set) var output: [String: Any?]? {
        get {
            var output: [String: Any?]? = nil
            queue.sync {
                output = privateOutput
            }
            
            return output
        }
        set {
            queue.async(flags: .barrier) {
                self.privateOutput = newValue
            }
        }
    }
    
    typealias Field = String
    typealias Rules = [LivrRule]
    
    typealias RuleName = String
    typealias RuleArguments = Any
    
    /// Private validationRules property - holds the dictionary of validation rules
    private var privateValidationRules: [String: Any?]?
    
    /// public validationRules property - applies thread safety to the output dictionary
    private(set) var validationRules: [String: Any?]? {
        get {
            var validationRules: [String: Any?]? = nil
            queue.sync {
                validationRules = privateValidationRules
            }
            
            return validationRules
        }
        set {
            queue.async(flags: .barrier) {
                self.privateValidationRules = newValue
            }
        }
    }
    
    /// Private preparedRulesByField property - holds the rules for each field once the validator is built
    private var privatePreparedRulesByField: [Field: Rules]?
    
    /// preparedRulesByField property - applies thread safety to the preparedRulesByField dictionary
    private var preparedRulesByField: [Field: Rules]? {
        get {
            var preparedRulesByField: [Field: Rules]? = nil
            queue.sync {
                preparedRulesByField = privatePreparedRulesByField
            }
    
            return preparedRulesByField
        }
        set {
            queue.async(flags: .barrier) {
                self.privatePreparedRulesByField = newValue
            }
        }
    }
    
    /// Private rulesByField property - holds the dictionary of rules for each field
    private var privateRulesByField: [Field: Rules]?
    
    /// public rulesByField property - applies thread safety to the rulesByField dictionary
    private(set) var rulesByField: [Field: Rules]? {
        get {
            var rulesByField: [Field: Rules]? = nil
            queue.sync {
                rulesByField = privateRulesByField
            }
            
            return rulesByField
        }
        set {
            queue.async(flags: .barrier) {
                self.privateRulesByField = newValue
            }
        }
    }
    
    /// Private validatingData property - holds the dictionary of data that is beign validated
    private var privateValidatingData: [String: Any?]?
    
    /// public validatingData property - applies thread safety to the validatingData dictionary
    public private(set) var validatingData: [String: Any?]? {
        get {
            var validatingData: [String: Any?]? = nil
            queue.sync {
                validatingData = privateValidatingData
            }
            
            return validatingData
        }
        set {
            queue.async(flags: .barrier) {
                self.privateValidatingData = newValue
            }
        }
    }
    
    private var privateIsAutoTrim: Bool
    
    private(set) var isAutoTrim: Bool {
        get {
            var isAutoTrim: Bool = false
            queue.sync {
                isAutoTrim = privateIsAutoTrim
            }
            
            return isAutoTrim
        }
        set {
            queue.async(flags: .barrier) {
                self.privateIsAutoTrim = newValue
            }
        }
    }
    
    private var privateAllRequired: Bool = false
    
    public var allRequired: Bool {
        get {
            var allRequired: Bool = false
            queue.sync {
                allRequired = privateAllRequired
            }
            
            return allRequired
        }
        set {
            queue.async(flags: .barrier) {
                self.privateAllRequired = newValue
            }
        }
    }
    
    public typealias Output = [String: Any?]
    
    public enum ErrorType: Error {
        case notRegistered(rule: String),
        nilValidationRules,
        emptyAliasName, emptyAliasRules,
        wrongArguments(rule: String, reason: String)
        
        public var description: String {
            switch self {
            case .notRegistered(let ruleName):
                return "Rule [" + ruleName + "] not registered"
            case .wrongArguments(let ruleName, let reason):
                return "Rule [" + ruleName + "]: " + reason
            case .emptyAliasName:
                return "Alias should have a name key containing it's String name"
            case .emptyAliasRules:
                return "Alias should have a rules key containing it's rules"
            default:
                return "validation rules should not be nil"
            }
        }
    }
    
    // MARK: - Register + Rules of validation
    init(isAutoTrim: Bool) {
        self.privateIsAutoTrim = isAutoTrim
    }
    
    init(validationRules: [String: Any?], isAutoTrim: Bool = true) {
        self.privateValidationRules = validationRules
        self.privateIsAutoTrim = isAutoTrim
    }
    
    /// a validator for rules that are already prepared (nested_object, list_of_objects, ...)
    init(rulesByField: [String: [LivrRule]], isAutoTrim: Bool) {
        self.privateValidationRules = [:]
        self.privatePreparedRulesByField = rulesByField
        self.privateIsAutoTrim = isAutoTrim
    }
    
    /// rules that create validators (nested_object, list_of, aliases, ...) use the same automatic trim setting
    private func setAutoTrim(in rules: inout [LivrRule]) {
        for (index, rule) in rules.enumerated() {
            if var ruleThatCreatesValidator = rule as? LivrRule & RuleThatCreatesValidator {
                ruleThatCreatesValidator.isAutoTrim = isAutoTrim
                rules[index] = ruleThatCreatesValidator
            }
        }
    }
    
    private func insertCommonRulesIfNeeded(in rules: inout [LivrRule]) {
        setAutoTrim(in: &rules)
        allRequired ? rules.insert(CommonRules.Required(), at: 0) : ()
        // the automatic trim comes first, so the other rules get the trimmed value
        if isAutoTrim {
            var autoTrim = ModifiersRules.Trim()
            autoTrim.isAutoTrim = true
            rules.insert(autoTrim, at: 0)
        }
    }
    
    /// with automatic trim, rules that compare fields get the trimmed value of the other field
    private func autoTrimmedIfNeeded(_ data: [String: Any?]) -> [String: Any?] {
        guard isAutoTrim else { return data }
        return data.mapValues { (value: Any?) -> Any? in
            guard let string = value as? String else { return value }
            return string.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    public func registerRule(aliases: [[String: Any?]]) throws {
        
        for alias in aliases {
            guard let name = alias["name"] as? String else {
                throw ErrorType.emptyAliasName
            }
            guard let optionalRules = alias["rules"], let rules = optionalRules else {
                throw ErrorType.emptyAliasRules
            }
            let errorCode = alias["error"] as? String
            
            self.registerRule(alias: name, rules: rules, errorCode: errorCode)            
        }
    }
    
    public func register(customRule: CustomRule) {
        LIVR.register(rule: customRule)
        preparedRulesByField = nil
    }
    
    public func registerRule(alias: String, rules: Any, errorCode: String? = nil) {
        
        let ruleAlias = RuleAlias(name: alias, errorCode: errorCode, rules: rules, isAutoTrim: isAutoTrim)
        LIVR.register(rule: ruleAlias)
        preparedRulesByField = nil
    }
    
    /// Builds the rules of the validator. A rule that is not registered or has wrong arguments
    /// throws (a schema error). Calling it first is optional: `validate(data:)` builds the rules too
    /// and throws the same errors.
    public func prepare() throws {
        guard preparedRulesByField == nil else { return }
        guard let validationRules = validationRules else { throw ErrorType.nilValidationRules }
        preparedRulesByField = try Validator.rulesByField(from: validationRules)
    }
    
    static func rulesByField(from validationRules: [String: Any?]) throws -> [Field: Rules] {
        var rulesByField: [Field: Rules] = [:]
        for (field, validationRules) in validationRules {
            if let rules = try RuleGenerator.generateRules(from: validationRules) {
                rulesByField[field] = rules
            }
        }
        return rulesByField
    }
    
    // MARK: - Validating
    
    @discardableResult
    public func validate(data: [String: Any?]) throws -> Output? {
        
        try prepare()
        rulesByField = preparedRulesByField
        
        // the validator can be used more than once
        errors = nil
        // valid data without any of the fields gives an empty output
        output = [:]
        validatingData = autoTrimmedIfNeeded(data)
        
        guard let rulesByField = rulesByField else { return nil }
        for case let field in rulesByField.keys {
            if let value = data[field] {
                validate(value, for: field)
            } else {
                validate(nil, for: field, asInputed: false)
            }
        }
        
        validatingData = nil
        
        if errors != nil {
            return nil
        }
        return output
    }
    
    // to validate single values within its rules
    
    @discardableResult
    public func validate(value: Any?, validationRules: Any?) -> (LivrRule.Errors, LivrRule.UpdatedValue?) {
        
        let rules = try? RuleGenerator.generateRules(from: validationRules)
        guard let fieldRules = rules ?? nil else { return (nil, nil) }
        return validate(value: value, fieldRules: fieldRules)
    }
    
    /// validates a value without a containing object (an item of list_of, a value of values) with the
    /// rules of a field, including the automatic trim
    func validate(value: Any?, fieldRules rules: [LivrRule]) -> (LivrRule.Errors, LivrRule.UpdatedValue?) {
        
        var rules = rules
        insertCommonRulesIfNeeded(in: &rules)
        return validate(value: value, rules: rules)
    }
    
    @discardableResult
    public func validate(value: Any?, rules: [LivrRule]) -> (LivrRule.Errors, LivrRule.UpdatedValue?) {
        return validate(value: value, rules: rules, in: nil)
    }
    
    /// the rules of aliases, or and when see the object that contains the field
    func validate(value: Any?, rules: [LivrRule], in object: [String: Any?]?) -> (LivrRule.Errors, LivrRule.UpdatedValue?) {
        
        var rules = rules
        setAutoTrim(in: &rules)
        
        var updatedValue: AnyObject?
        for rule in rules {
            // each rule gets the value updated by the previous ones
            let errorAndUpdatedValue = rule.validate(value: updatedValue ?? value, in: object)
            
            if let error = errorAndUpdatedValue.0 {
                return (error, nil)
            } else if let updatedValueFromRule = errorAndUpdatedValue.1 {
                updatedValue = updatedValueFromRule
            }
        }
        return (nil, updatedValue)
    }
    
    private func validate(_ value: Any?, for field: String, asInputed isAnInputedValue: Bool = true) {
        
        guard var rules = rulesByField?[field] else { return }
        insertCommonRulesIfNeeded(in: &rules)
        
        // each rule gets the value updated by the previous ones
        var value = value
        let validatingData = self.validatingData
        for rule in rules {
            let errorAndUpdatedValue = rule.validate(value: value, in: validatingData)
            if let error = errorAndUpdatedValue.0 {
                errors == nil ? errors = [:] : ()
                errors?[field] = error
                output = nil
                break
            } else if errors == nil && (isAnInputedValue || errorAndUpdatedValue.1 != nil) {
                output == nil ? output = [:] : ()
                
                if rule is MetaRules.NestedObject {
                    output?[field] = errorAndUpdatedValue.1 ?? value
                } else if output?[field] == nil {
                    output?[field] = errorAndUpdatedValue.1 ?? value
                } else if let updatedValue = errorAndUpdatedValue.1 {
                    output?[field] = updatedValue
                }
            }
            
            if let updatedValue = errorAndUpdatedValue.1 {
                value = updatedValue
            }
        }
        
        rulesByField?.removeValue(forKey: field)
    }
}
