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
    private mutating func setRulesByField() throws {
        rulesByField = [:]
        
        for pairOfFieldAndValidationRules in validationRules {
            let field = pairOfFieldAndValidationRules.key
            let validationRules = pairOfFieldAndValidationRules.value
            
            if let ruleName = validationRules as? String {
                guard let rule = try getRegisterdRule(with: ruleName, for: field) else { continue }
                
                rulesByField?[field] = [rule]
            } else if let namesOfRules = validationRules as? [String] {
                var rules: [LivrRule] = []
                for ruleName in namesOfRules {
                    guard let rule = try getRegisterdRule(with: ruleName, for: field) else { continue }
                    
                    rules.append(rule)
                }
                
                rulesByField?[field] = rules
            } else if let rulesObject = validationRules as? JSON {
                // analise json to get key and object
                if let ruleObject = rulesObject.first {
                    let ruleName = ruleObject.key
                    guard let rule = try getRegisterdRule(with: ruleName, for: field) else { continue }
                    
                    rulesByField?[field] = [rule]
                }
            } else if let rulesObjects = validationRules as? [JSON] {
                // analise json to get key and object
                if let ruleObject = rulesObjects.first?.first {
                    let ruleName = ruleObject.key
                    guard let rule = try getRegisterdRule(with: ruleName, for: field) else { continue }
                    
                    rulesByField?[field] = [rule]
                }
            }
        }
    }
    
    private mutating func getRegisterdRule(with ruleName: String, for field: String) throws -> LivrRule? {
        guard let rule = allAvailableRules?[ruleName] else {
            throw ValidatingError.notRegistered(rule: ruleName)
        }
        return rule
    }
    
    // MARK: - Validate + Trim
    mutating func validate(data: JSON) throws -> (Output?, Errors?) {
        
        try setRulesByField()
        
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
            let errorAndUpdatedValue = rule.validate(value: value)
            if let error = errorAndUpdatedValue.0 {
                errors == nil ? errors = [:] : ()
                errors?[field] = error as AnyObject
            } else {
                output == nil ? output = [:] : ()
                output?[field] = errorAndUpdatedValue.1 ?? value as AnyObject
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
