//
//  Validator.swift
//  Pods-Livr
//
//  Created by Felipe Lefèvre Marino on 9/14/18.
//

public struct Validator {
    
    public private(set) var errors: JSON?
    public private(set) var output: JSON?
    
    typealias Field = String
    typealias Rules = [LivrRule]
    
    typealias RuleName = String
    typealias RuleArguments = Any
    
    private(set) var validationRules: JSON?
    private(set) var rulesByField: [Field: Rules]?
    private(set) var validatingData: JSON?
    
    private(set) var isAutoTrim: Bool
    
    public typealias Output = JSON
    
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
        self.isAutoTrim = isAutoTrim
    }
    
    init(validationRules: JSON, isAutoTrim: Bool = true) {
        self.validationRules = validationRules
        self.isAutoTrim = isAutoTrim
    }
    
    public func registerRule(aliases: [JSON]) throws {
        
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
    
    // TODO: func that receives alias name + function
    // or even better a subclass o alias rule to be registered
    
    public func registerRule(alias: String, rules: Any, errorCode: LivrRule.ErrorCode? = nil) {
        
        let ruleAlias = RuleAlias(name: alias, errorCode: errorCode, rules: rules, isAutoTrim: isAutoTrim)
        LIVR.register(rule: ruleAlias)
    }
    
    private mutating func setRulesByField() throws {
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
    
    public mutating func validate(data: JSON) throws -> Output? {
        
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
    public func validate(value: Any?, validationRules: Any?) -> (LivrRule.Errors?, LivrRule.UpdatedValue?) {
        
        guard var rules = RuleGenerator.generateRules(from: validationRules) else { return (nil, nil) }
        isAutoTrim ? rules.insert(ModifiersRules.Trim(), at: 0) : ()
        return validate(value: value, rules: rules)
    }
    
    public func validate(value: Any?, rules: [LivrRule]) -> (LivrRule.Errors?, LivrRule.UpdatedValue?) {
        
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
    
    mutating private func validate(_ value: Any?, for field: String, asInputed isAnInputedValue: Bool = true) {
        
        guard var rules = rulesByField?[field] else { return }
        
        isAutoTrim ? rules.insert(ModifiersRules.Trim(), at: 0) : ()
        
        for (index, rule) in rules.enumerated() {
            if var equalToFieldRule = rule as? SpecialRules.EqualToField {
                if let fieldToCompareValue = (rule as? SpecialRules.EqualToField)?.arguments as? String, let validatingData = validatingData, let valueToCompare = validatingData[fieldToCompareValue] {
                    
                    equalToFieldRule.otherFieldValue = valueToCompare
                    rules[index] = equalToFieldRule
                } else if let arguments = (rule as? SpecialRules.EqualToField)?.arguments as? [Any], let fieldToCompareValue = arguments.first as? String,
                    let validatingData = validatingData, let valueToCompare = validatingData[fieldToCompareValue] {
                    
                    equalToFieldRule.otherFieldValue = valueToCompare
                    rules[index] = equalToFieldRule
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
