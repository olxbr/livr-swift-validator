//
//  Validator.swift
//  Pods-Livr
//
//  Created by Felipe Lefèvre Marino on 9/14/18.
//

struct Validator {
    
    private(set) var errors: JSON?
    private(set) var output: JSON?
    
    private(set) var allAvailableRules: LivrRulesDict?
    
    typealias Field = String
    typealias Rules = [LivrRule]
    private(set) var rulesByField: [Field: Rules]?
    
    typealias Output = JSON
    typealias Errors = JSON
    
    init(validationRules: JSON) {
        setRulesByField(for: validationRules)
    }
    
    // FIXME: This basic stage do not considers nested objects nor any complex rules, aliased rules and whatsoever - doing the most simple way for each step
    private mutating func setRulesByField(for validationRules: JSON) {
        rulesByField = [:]
        
        for pairOfFieldAndValidationRules in validationRules {
            let field = pairOfFieldAndValidationRules.key
            let validationRules = pairOfFieldAndValidationRules.value
            
            if let ruleName = validationRules as? String {
                guard let rule = allAvailableRules?[ruleName] else {
                    // LOG or throw error - Rule [' + ruleName + '] not registered
                    continue
                }
                
                rulesByField?[field] = [rule]
            } else if let rulesNames = validationRules as? [String] {
                var rules: [LivrRule] = []
                for ruleName in rulesNames {
                    guard let rule = allAvailableRules?[ruleName] else {
                        // LOG or throw error - Rule [' + ruleName + '] not registered
                        continue
                    }
                    
                    rules.append(rule)
                }
                
                rulesByField?[field] = rules
            }
        }
    }
    
    mutating func validate(data: JSON) -> (Output?, Errors?) {
        
        for pairOfFieldNameAndValue in data {
            let field = pairOfFieldNameAndValue.key
            let value = pairOfFieldNameAndValue.value
            
            validate(value, for: field)
        }
        
        return (nil, errors)
    }
    
    mutating private func validate(_ value: Any, for field: String) {
        // now it treats as a single rule by field only
        guard let rules = rulesByField?[field] else {
            // TODO: log console error for rule not in received rules
            return
        }
        
        for rule in rules {
            if let error = rule.validate(value: value) {
                errors?[field] = error
            } else {
                output?[field] = value
                // TODO: trim if needed
            }
        }
    }
    
    mutating func register(_ rules: LivrRulesDict) {
        self.allAvailableRules = rules
    }
    
    private func autoTrim(data: Any) -> Any {
        if var data = data as? [JSON] {
            for (index, _) in data.enumerated() {
                data[index].trim()
            }
        } else if var data = data as? JSON {
            return data.trim()
        }
        
        return data
    }
}
