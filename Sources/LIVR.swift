//
//  LIVR.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/18/18.
//

typealias LivrRulesDict = [String: LivrRule]

struct LIVR {
    
    static var defaultRules: LivrRulesDict = [Common.Required.name: Common.Required()]
    
    public static func validator() -> Validator {
        var validator = Validator()
        validator.register(defaultRules)
        return validator
    }
}
