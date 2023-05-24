//
//  ExtraRules.swift
//  LivrCommonCustomRules
//
//  Created by Felipe Marino on 03/07/19.
//  Copyright © 2019 Zap SA Internet. All rights reserved.
//

import Foundation
import Livr

public struct CustomRules {
    
    public struct GreaterThanOrEqualToField: LivrRule, RuleThatCompareFields, CustomRule {
        public var name: String = "greater_eq_than_field"
        public var rules: Any?
        public var customErrorCode: String? = "NOT_GREATER_OR_EQUAL_TO_FIELD"
        public var errorCode: LIVR.ErrorCode = .fieldsNotEqual
        public var arguments: Any?
        public var otherFieldValue: Any?
        
        public init() {}
        
        public func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                // handles primitive and non-primitive data
                if Utils.isPrimitive(value) {
                    let stringValue = String(describing: value)
                    
                    guard let otherFieldValue = otherFieldValue,
                        Float(stringValue) ?? 0.0 >= Float(String(describing: otherFieldValue)) ?? 1.0 else {
                            return (OutputError(errors: customErrorCode), nil)
                    }
                    
                    return (nil, nil)
                } else {
                    let valueAsArray = value as? [Any]
                    let otherFieldAsArray = otherFieldValue as? [Any]
                    
                    guard valueAsArray?.isEmpty == false && otherFieldAsArray?.isEmpty == false else {
                        return (nil, nil)
                    }
                    
                    guard valueAsArray?.count == otherFieldAsArray?.count else {
                        return (OutputError(errors: String.differentLengthThan, args: [self.name: otherFieldAsArray]), nil)
                    }
                    
                    for (index, value) in valueAsArray!.enumerated() {
                        let valueToCompareAsString = String(describing: otherFieldAsArray![index])
                        let valueAsString = String(describing: value)
                        
                        if Double(valueAsString) ?? 0 < Double(valueToCompareAsString) ?? 1 {
                            return (OutputError(errors: customErrorCode, args: [self.name: otherFieldAsArray]), nil)
                        }
                    }
                }
            }
            return (nil, nil)
        }
    }

    public struct RequiredIf: LivrRule, RuleThatCompareFields, CustomRule {
        public var name: String = "required_if"
        public var rules: Any?
        public var customErrorCode: String?
        public var errorCode: LIVR.ErrorCode = .required
        public var arguments: Any?
        public var otherFieldValue: Any?
        public var isAutoTrim: Bool = true

        public init() {}

        public func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            guard !Utils.hasNoValue(otherFieldValue) else { return (nil, nil) }
            guard let validationRules = arguments as? [String: Any?] else { return (OutputError(errors: LIVR.ErrorCode.format.rawValue), nil) }
            let validator = LIVR.validator(isAutoTrim: isAutoTrim)
            let validatorOutput = validator.validate(value: otherFieldValue, validationRules: Array(validationRules.values))
            guard validatorOutput.0 == nil else { return (nil, nil) }
            guard !Utils.hasNoValue(value) else { return (OutputError(errors: errorCode.rawValue, args: [self.name: otherFieldValue]), nil) }
            return (nil, nil)
        }
    }

    public struct NotEmptyListIf: LivrRule, RuleThatCompareFields, CustomRule {
        public var name: String = "not_empty_list_if"
        public var rules: Any?
        public var customErrorCode: String?
        public var errorCode: LIVR.ErrorCode = .cannotBeEmpty
        public var arguments: Any?
        public var otherFieldValue: Any?
        public var isAutoTrim: Bool = true

        public init() {}

        public func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            guard !Utils.hasNoValue(otherFieldValue) else { return (nil, nil) }
            guard let validationRules = arguments as? [String: Any?] else { return (OutputError(errors: LIVR.ErrorCode.format.rawValue), nil) }
            let validator = LIVR.validator(isAutoTrim: isAutoTrim)
            let validatorOutput = validator.validate(value: otherFieldValue, validationRules: Array(validationRules.values))
            guard validatorOutput.0 == nil else { return (nil, nil) }
            guard !Utils.hasNoValue(value) else { return (OutputError(errors: errorCode.rawValue, args: [self.name: otherFieldValue]), nil) }
            guard let value = value as? Array<Any>, !value.isEmpty else { return (OutputError(errors: errorCode.rawValue, args: [self.name: otherFieldValue]), nil) }
            return (nil, nil)
        }
    }
}

private extension String {
    static let differentLengthThan = "VALIDATION_ERROR_DIFFERENT_LENGTH_THAN"
}
