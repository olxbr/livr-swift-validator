//
//  Validator.swift
//  Pods-Livr
//
//  Created by Felipe Lefèvre Marino on 9/14/18.
//

enum ValidatingError: Error {
    case notRegistered(rule: String)
    
    var description: String {
        switch self {
        case .notRegistered(let ruleName):
            return "Rule [" + ruleName + "] not registered"
        }
    }
}

struct Validator {
    
    private(set) var errors: JSON?
    private(set) var output: JSON?
    
    typealias Field = String
    typealias Rules = [LivrRule]
    
    typealias RuleName = String
    typealias RuleArguments = Any
    
    private(set) var validationRules: JSON
    private(set) var rulesByField: [Field: Rules]?
    private(set) var validatingData: JSON?
    
    private(set) var isAutoTrim: Bool
    
    typealias Output = JSON
    
    // MARK: - Register + Rules of validation
    init(validationRules: JSON, isAutoTrim: Bool = true) {
        self.validationRules = validationRules
        self.isAutoTrim = isAutoTrim
    }
    
    private mutating func setRulesByField() throws {
        rulesByField = [:]
        
        for pairOfFieldAndValidationRules in validationRules {
            let field = pairOfFieldAndValidationRules.key
            let validationRules = pairOfFieldAndValidationRules.value
            
            if let rules = RuleGenerator.generateRules(from: validationRules) {
                rulesByField?[field] = rules
            }
        }
    }
    
    // MARK: - Validate + Trim
    mutating func validate(data: JSON) throws -> Output? {
        
        try setRulesByField()
        
        validatingData = data
        
        guard let rulesByField = rulesByField else {
            return nil //see what to return
        }
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
    static func validate(value: Any?, validationRules: Any?) -> (LivrRule.Errors?, LivrRule.UpdatedValue?) {
        
        guard let rules = RuleGenerator.generateRules(from: validationRules) else { return (nil, nil) } // TODO: see if this is the correct return
        return Validator.validate(value: value, rules: rules)
    }
    
    static func validate(value: Any?, rules: [LivrRule], autoTrim: Bool = true) -> (LivrRule.Errors?, LivrRule.UpdatedValue?) {
        
        var rules = rules
        autoTrim ? rules.append(ModifiersRules.Trim()) : ()
        
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
        // now it treats as a single rule by field only
        guard var rules = rulesByField?[field] else {
            // TODO: log console error for rule not in received rules
            return
        }
        
        isAutoTrim ? rules.append(ModifiersRules.Trim()) : ()
        
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
                } else if output?[field] == nil { // TODO: improve to see if is any modifiers using a protocol or inheritance
                    output?[field] = errorAndUpdatedValue.1 ?? value
                } else if let updatedValue = errorAndUpdatedValue.1 {
                    output?[field] = updatedValue
                }
                // TODO: trim if needed
            }
        }
        
        rulesByField?.removeValue(forKey: field)
    }
}
