//
//  RuleGenerator.swift
//  Livr
//
//  Created by Felipe Lefèvre Marino on 9/30/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

struct RuleGenerator {
    
    static func generateRules(from validationRules: Any?) -> [LivrRule]? {
        
        if let ruleName = validationRules as? String {
            if let rule = try? getRegisterdRule(with: ruleName) {
                return [rule]
            }
            return nil
        } else if let namesOfRules = validationRules as? [String] {
            var rules: [LivrRule] = []
            for ruleName in namesOfRules {
                if let rule = try? getRegisterdRule(with: ruleName) {
                    rules.append(rule)
                }
            }
            return rules
        } else if let rulesObject = validationRules as? [String: Any?] {
            // analise json to get key and object
            if let ruleObject = rulesObject.first {
                let ruleName = ruleObject.key
                if var rule = try? getRegisterdRule(with: ruleName) {
                    rule.arguments = ruleObject.value
                    return [rule]
                }
            }
        } else if let rulesObjects = validationRules as? [Any] {
            
            if let rulesObjectsAsArray = rulesObjects as? [[Any]], let rulesObjects = rulesObjectsAsArray.first {
                return RuleGenerator.rules(for: rulesObjects)
            }
            return RuleGenerator.rules(for: rulesObjects)
        }
        
        return nil
    }
    
    private static func rules(for arrayOfRulesObjects: [Any]) -> [LivrRule]? {
        var fieldRules: [LivrRule] = []
        
        for rule in arrayOfRulesObjects {
            
            if let arrayOfRules = rule as? [Any], let rules = RuleGenerator.rules(for: arrayOfRules) {
                fieldRules.append(contentsOf: rules)
            } else if let ruleName = rule as? String {
                if let rule = try? getRegisterdRule(with: ruleName) {
                    fieldRules.append(rule)
                }
            } else if let ruleObject = rule as? [String: Any?], let firstRuleObject = ruleObject.first {
                if var rule = try? getRegisterdRule(with: firstRuleObject.key) {
                    rule.arguments = firstRuleObject.value
                    fieldRules.append(rule)
                }
            }
        }
        return fieldRules
    }

    private static func getRegisterdRule(with ruleName: String) throws -> LivrRule? {
        guard let rule = LIVR.defaultRules[ruleName] else {
            throw Validator.ErrorType.notRegistered(rule: ruleName)
        }
        
        return rule
    }
}
