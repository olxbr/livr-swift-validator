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
    
    typealias RuleName = String
    typealias RuleArguments = Any
    
    private(set) var validationRules: JSON
    private(set) var rulesByField: [Field: Rules]?
    
    typealias OutputOrErrors = JSON
    
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
                    guard var rule = try getRegisterdRule(with: ruleName, for: field) else { continue }
                    rule.arguments = ruleObject.value
                    
                    rulesByField?[field] = [rule]
                }
            } else if let rulesObjects = validationRules as? [JSON] {
                // analise json to get key and object
                if let ruleObject = rulesObjects.first?.first {
                    let ruleName = ruleObject.key
                    guard var rule = try getRegisterdRule(with: ruleName, for: field) else { continue }
                    rule.arguments = ruleObject.value
                    
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
    mutating func validate(data: JSON) throws -> OutputOrErrors? {
        
        try setRulesByField()
        
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
        
        if let errors = errors {
            return errors
        }
        return output
    }
    
    mutating private func validate(_ value: Any?, for field: String, asInputed isAnInputedValue: Bool = true) {
        // now it treats as a single rule by field only
        guard let rules = rulesByField?[field] else {
            // TODO: log console error for rule not in received rules
            return
        }
        
        for rule in rules {
            let errorAndUpdatedValue = rule.validate(value: value)
            if let error = errorAndUpdatedValue.0 {
                errors == nil ? errors = [:] : ()
                errors?[field] = error
                output = nil
            } else if errors == nil && isAnInputedValue {
                output == nil ? output = [:] : ()
                output?[field] = errorAndUpdatedValue.1 ?? value
                // TODO: trim if needed
            }
        }
        
        rulesByField?.removeValue(forKey: field)
    }
}
