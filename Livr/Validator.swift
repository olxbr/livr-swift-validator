//
//  Validator.swift
//  Pods-Livr
//
//  Created by Felipe Lefèvre Marino on 9/14/18.
//

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
    
    enum ErrorType: Error {
        case notRegistered(rule: String),
        nilValidationRules,
        emptyAliasName, emptyAliasRules
        
        var description: String {
            switch self {
            case .notRegistered(let ruleName):
                return "Rule [" + ruleName + "] not registered"
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
    
    private func insertCommonRulesIfNeeded(in rules: inout [LivrRule]) {
        isAutoTrim ? rules.insert(ModifiersRules.Trim(), at: 0) : ()
        allRequired ? rules.insert(CommonRules.Required(), at: 0) : ()
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
    }
    
    public func registerRule(alias: String, rules: Any, errorCode: String? = nil) {
        
        let ruleAlias = RuleAlias(name: alias, errorCode: errorCode, rules: rules, isAutoTrim: isAutoTrim)
        LIVR.register(rule: ruleAlias)
    }
    
    private func setRulesByField() throws {
        guard let validationRules = validationRules else { throw ErrorType.nilValidationRules }
        rulesByField = [:]
        
        for pairOfFieldAndValidationRules in validationRules {
            let field = pairOfFieldAndValidationRules.key
            let validationRules = pairOfFieldAndValidationRules.value
            
            if let rules = RuleGenerator.generateRules(from: validationRules) {
                rulesByField?[field] = rules
            }
        }
    }
    
    // MARK: - Validating
    
    @discardableResult
    public func validate(data: [String: Any?]) throws -> Output? {
        
        try setRulesByField()
        
        validatingData = data
        
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
        
        guard var rules = RuleGenerator.generateRules(from: validationRules) else { return (nil, nil) }
        insertCommonRulesIfNeeded(in: &rules)
        return validate(value: value, rules: rules)
    }
    
    @discardableResult
    public func validate(value: Any?, rules: [LivrRule]) -> (LivrRule.Errors, LivrRule.UpdatedValue?) {
        
        var updatedValue: AnyObject?
        for rule in rules {
            let errorAndUpdatedValue = rule.validate(value: value)
            
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
        
        for (index, rule) in rules.enumerated() {
            if var ruleThatCompareFields = rule as? RuleThatCompareFields {
                if let fieldToCompareValue = rule.arguments as? String, let validatingData = validatingData, let valueToCompare = validatingData[fieldToCompareValue] {
                    
                    ruleThatCompareFields.otherFieldValue = valueToCompare
                    rules[index] = ruleThatCompareFields
                } else if let arguments = rule.arguments as? [Any], let fieldToCompareValue = arguments.first as? String,
                    let validatingData = validatingData, let valueToCompare = validatingData[fieldToCompareValue] {
                    
                    ruleThatCompareFields.otherFieldValue = valueToCompare
                    rules[index] = ruleThatCompareFields
                }
            }
            
            let errorAndUpdatedValue = rules[index].validate(value: value)
            if let error = errorAndUpdatedValue.0 {
                errors == nil ? errors = [:] : ()
                errors?[field] = error
                output = nil
            } else if errors == nil && (isAnInputedValue || rule is ModifiersRules.Default) {
                output == nil ? output = [:] : ()
                
                if rule is MetaRules.NestedObject {
                    output?[field] = errorAndUpdatedValue.1 ?? [:]
                } else if output?[field] == nil {
                    output?[field] = errorAndUpdatedValue.1 ?? value
                } else if let updatedValue = errorAndUpdatedValue.1 {
                    output?[field] = updatedValue
                }
            }
        }
        
        rulesByField?.removeValue(forKey: field)
    }
}
