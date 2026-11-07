//
//  RuleGenerator.swift
//  Livr
//
//  Created by Felipe Lefèvre Marino on 9/30/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

import Foundation

/// Builds the rules of a field. A rule whose arguments are wrong throws, and so does a rule that is
/// not registered (a schema error).
struct RuleGenerator {
    
    static func generateRules(from validationRules: Any?) throws -> [LivrRule]? {
        
        if let ruleName = validationRules as? String {
            return [try getRegisterdRule(with: ruleName, arguments: nil)]
        } else if let namesOfRules = validationRules as? [String] {
            return try namesOfRules.map { try getRegisterdRule(with: $0, arguments: nil) }
        } else if let rulesObject = validationRules as? [String: Any?] {
            // analise json to get key and object
            if let ruleObject = rulesObject.first {
                return [try getRegisterdRule(with: ruleObject.key, givenArguments: ruleObject.value)]
            }
        } else if let rulesObjects = validationRules as? [Any] {
            
            if let rulesObjectsAsArray = rulesObjects as? [[Any]], let rulesObjects = rulesObjectsAsArray.first {
                return try RuleGenerator.rules(for: rulesObjects)
            }
            return try RuleGenerator.rules(for: rulesObjects)
        }
        
        return nil
    }
    
    /// the rules that a LIVR 2.5 rule takes (when, values, keys): an empty list of rules is a schema error
    static func nonEmptyRules(from validationRules: Any?, of ruleName: String) throws -> [LivrRule] {
        guard let rules = try generateRules(from: validationRules), !rules.isEmpty else {
            throw Validator.ErrorType.wrongArguments(rule: ruleName, reason: "needs rules (\"any\" for no rules)")
        }
        return rules
    }
    
    /// a LIVR 2.5 rule without arguments: an argument is a schema error
    static func checkNoArguments(_ arguments: Any?, of ruleName: String) throws {
        if !Utils.argumentsList(arguments).isEmpty {
            throw Validator.ErrorType.wrongArguments(rule: ruleName, reason: "takes no arguments")
        }
    }
    
    static func wrongArguments(_ ruleName: String, _ arguments: Any?) -> Validator.ErrorType {
        return .wrongArguments(rule: ruleName, reason: "wrong arguments \(String(describing: arguments ?? "none"))")
    }
    
    private static func rules(for arrayOfRulesObjects: [Any]) throws -> [LivrRule] {
        var fieldRules: [LivrRule] = []
        
        for rule in arrayOfRulesObjects {
            
            if let arrayOfRules = rule as? [Any] {
                fieldRules.append(contentsOf: try RuleGenerator.rules(for: arrayOfRules))
            } else if let ruleName = rule as? String {
                fieldRules.append(try getRegisterdRule(with: ruleName, arguments: nil))
            } else if let ruleObject = rule as? [String: Any?], let firstRuleObject = ruleObject.first {
                fieldRules.append(try getRegisterdRule(with: firstRuleObject.key, givenArguments: firstRuleObject.value))
            }
        }
        return fieldRules
    }

    private static func getRegisterdRule(with ruleName: String, arguments: Any?) throws -> LivrRule {
        guard var rule = LIVR.defaultRules[ruleName] else {
            throw Validator.ErrorType.notRegistered(rule: ruleName)
        }
        
        rule.arguments = arguments
        try rule.prepare()
        return rule
    }
    
    /// a rule of the form {"rule": arguments}. {"rule": null} is one null argument for the LIVR 2.5 rules:
    /// on Apple platforms a JSON null (NSNull) becomes nil in [String: Any?], so nil is null for them.
    /// The LIVR 2.0 rules and custom rules get the arguments as they are.
    private static func getRegisterdRule(with ruleName: String, givenArguments arguments: Any?) throws -> LivrRule {
        let isLIVR25Rule = LIVR.defaultRules[ruleName] is PreDefinedRule && LIVR.namesOfLIVR25Rules.contains(ruleName)
        return try getRegisterdRule(with: ruleName, arguments: arguments == nil && isLIVR25Rule ? NSNull() : arguments)
    }
}
