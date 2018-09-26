//
//  Integer.swift
//  Livr
//
//  Created by Felipe Lefèvre Marino on 9/23/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

typealias DecimalNum = Decimal

struct NumericRules {
    
    // must be integer
    struct Integer: LivrRule {
        static var name = "integer"
        var errorCode = "NOT_INTEGER"
        
        init() {}
        
        func validate(value: Any?) -> (LivrRule.ErrorCode?, LivrRule.UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value: value) { return (.formatErrorCode, nil) }
                if !Utils.isNumber(value) {
                    if let stringValue = value as? String, let intValue = Int(stringValue) {
                        return (nil, intValue as AnyObject)
                    }
                    return (errorCode, nil)
                }
                if !(value is Int) { return (errorCode, nil) }
            }
            
            return (nil, nil)
        }
    }
    
    // must be a positive integer
    struct PositiveInteger: LivrRule {
        static var name = "positive_integer"
        var errorCode = "NOT_POSITIVE_INTEGER"
        
        init() {}
        
        func validate(value: Any?) -> (LivrRule.ErrorCode?, LivrRule.UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value: value) { return (.formatErrorCode, nil) }
                if !Utils.isNumber(value) {
                    if let stringValue = value as? String, let intValue = Int(stringValue), intValue > 0 {
                        return (nil, intValue as AnyObject)
                    }
                    return (errorCode, nil)
                }
                if let value = value as? Int, value < 1 { return (errorCode, nil) }
            }
            
            return (nil, nil)
        }
    }
    
    // must be decimal
    struct Decimal: LivrRule {
        static var name = "decimal"
        var errorCode = "NOT_DECIMAL"
        
        init() {}
        
        func validate(value: Any?) -> (LivrRule.ErrorCode?, LivrRule.UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value: value) { return (.formatErrorCode, nil) }
                if !Utils.isNumber(value) {
                    if let stringValue = value as? String {
                        if let intValue = Int(stringValue) {
                            return (nil, DecimalNum(intValue) as AnyObject)
                        } else if let doubleValue = Double(stringValue) {
                            return (nil, doubleValue as AnyObject)
                        }
                    }
                    return (errorCode, nil)
                }
                if !(value is Double) { return (errorCode, nil) }
            }
            return (nil, nil)
        }
    }
    
    // must be a positive decimal
    struct PositiveDecimal: LivrRule {
        static var name = "positive_decimal"
        var errorCode = "NOT_POSITIVE_DECIMAL"
        
        init() {}
        
        func validate(value: Any?) -> (LivrRule.ErrorCode?, LivrRule.UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value: value) { return (.formatErrorCode, nil) }
                if !Utils.isNumber(value) {
                    if let stringValue = value as? String {
                        if let intValue = Int(stringValue), intValue > 0 {
                            return (nil, DecimalNum(intValue) as AnyObject)
                        } else if let doubleValue = Double(stringValue), doubleValue > 0 {
                            return (nil, doubleValue as AnyObject)
                        }
                    }
                    return (errorCode, nil)
                }
                if let value = value as? Double, value < 1 { return (errorCode, nil) }
            }
            return (nil, nil)
        }
    }
}
