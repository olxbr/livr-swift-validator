//
//  Integer.swift
//  Livr
//
//  Created by Felipe Lefèvre Marino on 9/23/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

import Foundation

typealias DecimalNum = Decimal

struct NumericRules {
    
    // must be integer
    struct Integer: LivrRule, PreDefinedRule {
        static var name = "integer"
        var errorCode: LIVR.ErrorCode = .notInteger
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (OutputError(errors: LIVR.ErrorCode.format.rawValue), nil) }
                if !Utils.isNumber(value) {
                    if let stringValue = value as? String, let intValue = Int(stringValue) {
                        return (nil, intValue as AnyObject)
                    }
                    return (OutputError(errors: errorCode.rawValue), nil)
                }
                if !(value is Int) { return (OutputError(errors: errorCode.rawValue), nil) }
            }
            
            return (nil, nil)
        }
    }
    
    // must be a positive integer
    struct PositiveInteger: LivrRule, PreDefinedRule {
        static var name = "positive_integer"
        var errorCode: LIVR.ErrorCode = .notPositiveInteger
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (OutputError(errors: LIVR.ErrorCode.format.rawValue), nil) }
                if !Utils.isNumber(value) {
                    if let stringValue = value as? String, let intValue = Int(stringValue), intValue > 0 {
                        return (nil, intValue as AnyObject)
                    }
                    return (OutputError(errors: errorCode.rawValue), nil)
                }
                if let value = value as? Int, value < 1 { return (OutputError(errors: errorCode.rawValue), nil) }
            }
            
            return (nil, nil)
        }
    }
    
    // must be decimal
    struct Decimal: LivrRule, PreDefinedRule {
        static var name = "decimal"
        var errorCode: LIVR.ErrorCode = .notDecimal
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (OutputError(errors: LIVR.ErrorCode.format.rawValue), nil) }
                if !Utils.isNumber(value) {
                    if let stringValue = value as? String {
                        if let intValue = Int(stringValue) {
                            return (nil, DecimalNum(intValue) as AnyObject)
                        } else if let doubleValue = Double(stringValue) {
                            return (nil, doubleValue as AnyObject)
                        }
                    }
                    return (OutputError(errors: errorCode.rawValue), nil)
                }
                if !(value is Double) { return (OutputError(errors: errorCode.rawValue), nil) }
            }
            return (nil, nil)
        }
    }
    
    // must be a positive decimal
    struct PositiveDecimal: LivrRule, PreDefinedRule {
        static var name = "positive_decimal"
        var errorCode: LIVR.ErrorCode = .notPositiveDecimal
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (OutputError(errors: LIVR.ErrorCode.format.rawValue), nil) }
                if !Utils.isNumber(value) {
                    if let stringValue = value as? String {
                        if let intValue = Int(stringValue), intValue > 0 {
                            return (nil, DecimalNum(intValue) as AnyObject)
                        } else if let doubleValue = Double(stringValue), doubleValue > 0 {
                            return (nil, doubleValue as AnyObject)
                        }
                    }
                    return (OutputError(errors: errorCode.rawValue), nil)
                }
                if let value = value as? Double, value < 1 { return (OutputError(errors: errorCode.rawValue), nil) }
            }
            return (nil, nil)
        }
    }
    
    struct MaxNumber: LivrRule, PreDefinedRule {
        static var name = "max_number"
        var errorCode: LIVR.ErrorCode = .tooHigh
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value, let arguments = arguments {
                if !Utils.isPrimitive(value) { return (OutputError(errors: LIVR.ErrorCode.format.rawValue, args: [MaxNumber.name: arguments]), nil) }
                if !Utils.canBeCoercedToNumber(value) { return (OutputError(errors: LIVR.ErrorCode.notNumber.rawValue, args: [MaxNumber.name: arguments]), nil) }
                
                let maxValueAsString = String(describing: arguments)
                let inputedValueAsString = String(describing: value)
                
                if let valueAsInt = value as? Int, let maxValueAsInt = Int(maxValueAsString) {
                    if valueAsInt > maxValueAsInt {
                        return (OutputError(errors: errorCode.rawValue, args: [MaxNumber.name: arguments]), nil)
                    }
                    return (nil, nil)
                } else if let valueAsDouble = value as? Double, let maxValueAsDouble = Double(maxValueAsString) {
                    if valueAsDouble > maxValueAsDouble {
                        return (OutputError(errors: errorCode.rawValue, args: [MaxNumber.name: arguments]), nil)
                    }
                    return (nil, nil)
                } else if let inputedValueAsDouble = Double(inputedValueAsString), let maxValueAsDouble = Double(maxValueAsString) {
                    
                    if inputedValueAsDouble > maxValueAsDouble {
                        return (OutputError(errors: errorCode.rawValue, args: [MaxNumber.name: arguments]), nil)
                    }
                    
                    if inputedValueAsDouble.truncatingRemainder(dividingBy: 1) == 0 {
                        return (nil, Int(inputedValueAsDouble) as AnyObject)
                    }
                    return (nil, inputedValueAsDouble as AnyObject)
                }
                return (nil, nil)
            }
            return (nil, nil)
        }
    }
    
    struct MinNumber: LivrRule, PreDefinedRule {
        static var name = "min_number"
        var errorCode: LIVR.ErrorCode = .tooLow
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value, let arguments = arguments {
                if !Utils.isPrimitive(value) { return (OutputError(errors: LIVR.ErrorCode.format.rawValue, args: [MinNumber.name: arguments]), nil) }
                if !Utils.canBeCoercedToNumber(value) { return (OutputError(errors: LIVR.ErrorCode.notNumber.rawValue, args: [MinNumber.name: arguments]), nil) }
                
                let minValueAsString = String(describing: arguments)
                let inputedValueAsString = String(describing: value)
                
                if let valueAsInt = value as? Int, let minValueAsInt = Int(minValueAsString) {
                    if valueAsInt < minValueAsInt {
                        return (OutputError(errors: errorCode.rawValue, args: [MinNumber.name: arguments]), nil)
                    }
                    return (nil, nil)
                } else if let valueAsDouble = value as? Double, let minValueAsDouble = Double(minValueAsString) {
                    if valueAsDouble < minValueAsDouble {
                        return (OutputError(errors: errorCode.rawValue, args: [MinNumber.name: arguments]), nil)
                    }
                    return (nil, nil)
                } else if let inputedValueAsDouble = Double(inputedValueAsString), let minValueAsDouble = Double(minValueAsString) {
                    
                    if inputedValueAsDouble < minValueAsDouble {
                        return (OutputError(errors: errorCode.rawValue, args: [MinNumber.name: arguments]), nil)
                    }
                    
                    if inputedValueAsDouble.truncatingRemainder(dividingBy: 1) == 0 {
                        return (nil, Int(inputedValueAsDouble) as AnyObject)
                    }
                    return (nil, inputedValueAsDouble as AnyObject)
                }
                return (nil, nil)
            }
            return (nil, nil)
        }
    }
    
    struct NumberBetween: LivrRule, PreDefinedRule {
        static var name = "number_between"
        var errorCode: LIVR.ErrorCode = .format
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value, let arguments = arguments {
                if !Utils.isPrimitive(value) { return (OutputError(errors: LIVR.ErrorCode.format.rawValue, args: [NumberBetween.name: arguments]), nil) }
                if !Utils.canBeCoercedToNumber(value) { return (OutputError(errors: LIVR.ErrorCode.notNumber.rawValue, args: [NumberBetween.name: arguments]), nil) }
                
                let valueAsString = StringType(describing: value)
                
                if let arrayOfArguments = arguments as? [Any], let minAllowedValueArgument = arrayOfArguments.first, arrayOfArguments.count > 1 {
                    
                    let maxAllowedValueArgument = arrayOfArguments[1]
                    
                    let minAllowedValueAsString = String(describing: minAllowedValueArgument)
                    let maxAllowedValueAsString = String(describing: maxAllowedValueArgument)
                    
                    if let valueAsInt = value as? Int, let minAllowedValueAsInt = Int(minAllowedValueAsString),
                        let maxAllowedValueAsInt = Int(maxAllowedValueAsString) {
                        if valueAsInt < minAllowedValueAsInt {
                            return (OutputError(errors: LIVR.ErrorCode.tooLow.rawValue, args: [NumberBetween.name: arrayOfArguments]), nil)
                        } else if valueAsInt > maxAllowedValueAsInt {
                            return (OutputError(errors: LIVR.ErrorCode.tooHigh.rawValue, args: [NumberBetween.name: arrayOfArguments]), nil)
                        }
                        return (nil, nil)
                    } else if let valueAsDouble = value as? Double, let minAllowedValueAsDouble = Double(minAllowedValueAsString), let maxAllowedValueAsDouble = Double(maxAllowedValueAsString) {
                        if valueAsDouble < minAllowedValueAsDouble {
                            return (OutputError(errors: LIVR.ErrorCode.tooLow.rawValue, args: [NumberBetween.name: arrayOfArguments]), nil)
                        } else if valueAsDouble > maxAllowedValueAsDouble {
                            return (OutputError(errors: LIVR.ErrorCode.tooHigh.rawValue, args: [NumberBetween.name: arrayOfArguments]), nil)
                        }
                        return (nil, nil)
                    } else if let inputedValueAsDouble = Double(valueAsString), let minAllowedValueAsDouble = Double(minAllowedValueAsString), let maxAllowedValueAsDouble = Double(maxAllowedValueAsString) {
                        
                        if inputedValueAsDouble < minAllowedValueAsDouble {
                            return (OutputError(errors: LIVR.ErrorCode.tooLow.rawValue, args: [NumberBetween.name: arrayOfArguments]), nil)
                        } else if inputedValueAsDouble > maxAllowedValueAsDouble {
                            return (OutputError(errors: LIVR.ErrorCode.tooHigh.rawValue, args: [NumberBetween.name: arrayOfArguments]), nil)
                        }
                        
                        if inputedValueAsDouble.truncatingRemainder(dividingBy: 1) == 0 {
                            return (nil, Int(inputedValueAsDouble) as AnyObject)
                        }
                        return (nil, inputedValueAsDouble as AnyObject)
                    }
                    
                    return (nil, nil)
                }
            }
            return (nil, nil)
        }
    }
}
