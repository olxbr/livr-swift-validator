//
//  LivrRuleProtocol.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/18/18.
//

public protocol LivrRule {
    var arguments: Any? {get set}
    
    var errorCode: LIVR.ErrorCode {get}
    
    typealias Errors = Any?
    typealias UpdatedValue = AnyObject
    func validate(value: Any?) -> (Errors?, UpdatedValue?)
}

public protocol PreDefinedRule: LivrRule {
    static var name: String {get}
}

public protocol CustomRule: LivrRule {
    var name: String {get}
    var rules: Any? {get set}
    var customErrorCode: String? {get set}
}

public struct RuleAlias: CustomRule, RuleThatCreatesValidator {
    
    public var name: String
    public var errorCode: LIVR.ErrorCode = .format
    public var customErrorCode: String?
    public var rules: Any?
    public var arguments: Any?
    public var isAutoTrim: Bool
    
    public init(name: String, errorCode: String?, rules: Any, isAutoTrim: Bool) {
        self.name = name
        self.customErrorCode = errorCode
        self.rules = rules
        self.isAutoTrim = isAutoTrim
    }
    
    public func validate(value: Any?) -> (LivrRule.Errors?, LivrRule.UpdatedValue?) {
        
        let validator = Validator.init(isAutoTrim: isAutoTrim)
        if let rules = RuleGenerator.generateRules(from: self.rules) {
            let errorOrUpdatedValue = validator.validate(value: value, rules: rules)
            
            if let error = errorOrUpdatedValue.0 {
                if let customErrorCode = customErrorCode {
                    return (customErrorCode, nil)
                }
                return (error, nil)
            }
            return (nil, (errorOrUpdatedValue.1 ?? value) as AnyObject)
        }
        return (nil, nil)
    }
}
