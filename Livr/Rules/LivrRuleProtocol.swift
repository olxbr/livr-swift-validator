//
//  LivrRuleProtocol.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/18/18.
//

public protocol LivrRule {
    var arguments: Any? {get set}
    
    typealias ErrorCode = String
    var errorCode: ErrorCode {get}
    
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
}

public struct RuleAlias: CustomRule, RuleThatCreatesValidator {
    
    public var name: String
    public var errorCode: ErrorCode = ""
    public var rules: Any?
    public var arguments: Any?
    public var isAutoTrim: Bool
    
    public init(name: String, errorCode: ErrorCode?, rules: Any, isAutoTrim: Bool) {
        self.name = name
        errorCode != nil ? self.errorCode = errorCode! : ()
        self.rules = rules
        self.isAutoTrim = isAutoTrim
    }
    
    public func validate(value: Any?) -> (LivrRule.Errors?, LivrRule.UpdatedValue?) {
        
        let validator = Validator.init(isAutoTrim: isAutoTrim)
        if let rules = RuleGenerator.generateRules(from: self.rules) {
            let errorOrUpdatedValue = validator.validate(value: value, rules: rules)
            
            if let error = errorOrUpdatedValue.0 {
                if !self.errorCode.isEmpty {
                    return (errorCode, nil)
                }
                return (error, nil)
            }
            return (nil, (errorOrUpdatedValue.1 ?? value) as AnyObject)
        }
        return (nil, nil)
    }
}

public extension String {
    static let formatErrorCode = "FORMAT_ERROR"
    static let tooShortErrorCode = "TOO_SHORT"
    static let tooLongErrorCode = "TOO_LONG"
    static let tooLowErrorCode = "TOO_LOW"
    static let tooHighErrorCode = "TOO_HIGH"
    static let notNumberErrorCode = "NOT_NUMBER"
}
