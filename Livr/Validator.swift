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
    
    private(set) var validationRules: JSON
    private(set) var rulesByField: [Field: Rules]?
    
    typealias Output = JSON
    typealias Errors = JSON
    
    // MARK: - Register + Rules of validation
    mutating func register(_ rules: LivrRulesDict) {
        self.allAvailableRules = rules
    }
    
    init(validationRules: JSON) {
        self.validationRules = validationRules
    }
    
    // FIXME: This basic stage do not considers nested objects nor any complex rules, aliased rules and whatsoever - doing the most simple way for each step
    private mutating func setRulesByField() {
        rulesByField = [:]
        
        for pairOfFieldAndValidationRules in validationRules {
            let field = pairOfFieldAndValidationRules.key
            let validationRules = pairOfFieldAndValidationRules.value
            
            if let ruleName = validationRules as? String {
                guard let rule = getRegisterdRule(with: ruleName) else { continue }
                
                rulesByField?[field] = [rule]
            } else if let namesOfRules = validationRules as? [String] {
                var rules: [LivrRule] = []
                for ruleName in namesOfRules {
                    guard let rule = getRegisterdRule(with: ruleName) else { continue }
                    
                    rules.append(rule)
                }
                
                rulesByField?[field] = rules
            } else if let rulesObject = validationRules as? JSON {
                // analise json to get key and object
                if let ruleObject = rulesObject.first {
                    let ruleName = ruleObject.key
                    guard let rule = getRegisterdRule(with: ruleName) else { continue }
                    
                    rulesByField?[field] = [rule]
                }
            } else if let rulesObjects = validationRules as? [JSON] {
                // analise json to get key and object
                if let ruleObject = rulesObjects.first?.first {
                    let ruleName = ruleObject.key
                    guard let rule = getRegisterdRule(with: ruleName) else { continue }
                    
                    rulesByField?[field] = [rule]
                }
            }
        }
    }
    
    private func getRegisterdRule(with ruleName: String) -> LivrRule? {
        guard let rule = allAvailableRules?[ruleName] else {
            // LOG or throw error - Rule [' + ruleName + '] not registered
            return nil
        }
        return rule
    }
    
    // MARK: - Validate + Trim
    mutating func validate(data: JSON) -> (Output?, Errors?) {
        
        setRulesByField()
        
        for pairOfFieldNameAndValue in data {
            let field = pairOfFieldNameAndValue.key
            let value = pairOfFieldNameAndValue.value
            
            validate(value, for: field)
        }
        
        return (output, errors)
    }
    
    mutating private func validate(_ value: Any, for field: String) {
        // now it treats as a single rule by field only
        guard let rules = rulesByField?[field] else {
            // TODO: log console error for rule not in received rules
            return
        }
        
        for rule in rules {
            if let error = rule.validate(value: value) {
                errors == nil ? errors = [:] : ()
                errors?[field] = error as AnyObject
            } else {
                output == nil ? output = [:] : ()
                output?[field] = value as AnyObject
                // TODO: trim if needed
            }
        }
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
