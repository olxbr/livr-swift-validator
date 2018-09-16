//
//  Validator.swift
//  Pods-Livr
//
//  Created by Felipe Lefèvre Marino on 9/14/18.
//

struct Validator {
    
    typealias RuleFunction = () -> Void
    
    private(set) var defaultRules: [String: RuleFunction]?
    private(set) var livrRules: [String: RuleFunction]
    
    var isAutoTrim: Bool = true
    var isPrepared: Bool = false
    
    var validators: [String: RuleFunction]?
    var validatorBuilders: [String: RuleFunction]?
    var errors: [Error]?
    
    init(rules: [String: RuleFunction], isAutoTrim: Bool = true) {
        self.livrRules = rules
        self.isAutoTrim = isAutoTrim
    }

    mutating func register(defaultRules: [String: RuleFunction]) {
        for rule in defaultRules {
            self.defaultRules?[rule.key] = rule.value
        }
    }
    
    mutating func register(rules: [String: RuleFunction]) {
        for rule in rules {
            self.validatorBuilders?[rule.key] = rule.value
        }
    }
}

