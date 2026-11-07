//
//  LivrRuleProtocol.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/18/18.
//

import Foundation

public protocol LivrRule {
    var arguments: Any? {get set}
    
    var errorCode: LIVR.ErrorCode {get}
    
    typealias Errors = Any?
    typealias UpdatedValue = AnyObject
    func validate(value: Any?) -> (Errors?, UpdatedValue?)
    
    /// Checks the arguments when the validator is built: a wrong argument is a schema error.
    mutating func prepare() throws
    
    /// Validates the value of a field. `object` is the object that contains the field, nil for an
    /// item of a list: rules that read other fields (equal_to_field, required_if, when) read them there.
    func validate(value: Any?, in object: [String: Any?]?) -> (Errors?, UpdatedValue?)
}

public extension LivrRule {
    
    mutating func prepare() throws {}
    
    func validate(value: Any?, in object: [String: Any?]?) -> (Errors?, UpdatedValue?) {
        guard var ruleThatCompareFields = self as? RuleThatCompareFields else { return validate(value: value) }
        
        let otherField = arguments as? String ?? (arguments as? [Any])?.first as? String
        if let otherField = otherField, let otherFieldValue = object?[otherField] {
            ruleThatCompareFields.otherFieldValue = otherFieldValue
        }
        return ruleThatCompareFields.validate(value: value)
    }
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
    private var preparedRules: [LivrRule]?
    
    public init(name: String, errorCode: String?, rules: Any, isAutoTrim: Bool) {
        self.name = name
        self.customErrorCode = errorCode
        self.rules = rules
        self.isAutoTrim = isAutoTrim
    }
    
    public mutating func prepare() throws {
        preparedRules = try RuleGenerator.generateRules(from: rules)
    }
    
    public func validate(value: Any?) -> (LivrRule.Errors?, LivrRule.UpdatedValue?) {
        return validate(value: value, in: nil)
    }
    
    /// the rules of an alias see the object that contains the field
    public func validate(value: Any?, in object: [String: Any?]?) -> (LivrRule.Errors?, LivrRule.UpdatedValue?) {
        
        let validator = Validator.init(isAutoTrim: isAutoTrim)
        let rules = preparedRules ?? (try? RuleGenerator.generateRules(from: self.rules)) ?? nil
        if let rules = rules {
            let errorOrUpdatedValue = validator.validate(value: value, rules: rules, in: object)
            
            if let error = errorOrUpdatedValue.0 {
                if let customErrorCode = customErrorCode {
                    return (customErrorCode, nil)
                }
                return (error, nil)
            }
            // a missing value stays missing
            return (nil, errorOrUpdatedValue.1 ?? value.map { $0 as AnyObject })
        }
        return (nil, nil)
    }
}
