//
//  LIVR.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/18/18.
//

typealias LivrRulesDict = [String: LivrRule]

struct LIVR {
    
    static var defaultRules: LivrRulesDict = [Common.Required.name: Common.Required()]
    
    public static func validator(validationRules: JSON) -> Validator {
        var validator = Validator(validationRules: validationRules)
        validator.register(defaultRules)
        return validator
    }
}
