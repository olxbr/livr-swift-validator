//
//  ExtraRules.swift
//  LivrCommonCustomRules
//
//  Created by Felipe Marino on 03/07/19.
//  Copyright © 2019 Zap SA Internet. All rights reserved.
//

import Foundation
import Livr

struct CustomRules {
    
    struct GreaterThanOrEqualToField: LivrRule, RuleThatCompareFields, CustomRule {
        var name: String = "greater_eq_than_field"
        var rules: Any?
        var customErrorCode: String? = "NOT_GREATER_OR_EQUAL_TO_FIELD"
        var errorCode: LIVR.ErrorCode = .fieldsNotEqual
        var arguments: Any?
        var otherFieldValue: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                // handles primitive and non-primitive data
                if Utils.isPrimitive(value) {
                    let stringValue = String(describing: value)
                    
                    guard let otherFieldValue = otherFieldValue,
                        Float(stringValue) ?? 0.0 >= Float(String(describing: otherFieldValue)) ?? 1.0 else {
                            return (customErrorCode, nil)
                    }
                    
                    return (nil, nil)
                } else {
                    let valueAsArray = value as? [Any]
                    let otherFieldAsArray = otherFieldValue as? [Any]
                    
                    guard valueAsArray?.isEmpty == false && otherFieldAsArray?.isEmpty == false else {
                        return (nil, nil)
                    }
                    
                    guard valueAsArray?.count == otherFieldAsArray?.count else {
                        return (String.differentLengthThan, nil)
                    }
                    
                    for (index, value) in valueAsArray!.enumerated() {
                        let valueToCompareAsString = String(describing: otherFieldAsArray![index])
                        let valueAsString = String(describing: value)
                        
                        if Double(valueAsString) ?? 0 < Double(valueToCompareAsString) ?? 1 {
                            return (customErrorCode, nil)
                        }
                    }
                }
            }
            return (nil, nil)
        }
    }
}

private extension String {
    static let differentLengthThan = "VALIDATION_ERROR_DIFFERENT_LENGTH_THAN"
}
