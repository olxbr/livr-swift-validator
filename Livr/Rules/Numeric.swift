//
//  Integer.swift
//  Livr
//
//  Created by Felipe Lefèvre Marino on 9/23/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

typealias DecimalNum = Decimal

struct Numeric {
    
    // must be integer
    struct Integer: LivrRule {
        static var name = "integer"
        var errorCode = "NOT_INTEGER"
        
        init() {}
        
        func validate(value: Any?) -> (LivrRule.ErrorCode?, LivrRule.UpdatedValue?) {
            guard value as? Int != nil else {
                if let stringValue = value as? String {
                    if stringValue.isEmpty {
                        return (nil, nil)
                    } else if let intValue = Int(stringValue) {
                        return (nil, intValue as AnyObject)
                    }
                }
                return (errorCode, nil)
            }
            return (nil, nil)
        }
    }
    
    // must be integer
    struct PositiveInteger: LivrRule {
        static var name = "positive_integer"
        var errorCode = "NOT_POSITIVE_INTEGER"
        
        init() {}
        
        func validate(value: Any?) -> (LivrRule.ErrorCode?, LivrRule.UpdatedValue?) {
            guard let selfAsInt = value as? Int else {
                if let stringValue = value as? String {
                    if stringValue.isEmpty {
                        return (nil, nil)
                    } else if let intValue = Int(stringValue) {
                        if intValue < 0 {
                            return (errorCode, nil)
                        } else {
                            return (nil, intValue as AnyObject)
                        }
                    }
                }
                return (errorCode, nil)
            }
            if selfAsInt < 0 {
                return (errorCode, nil)
            } else {
                return (nil, nil)
            }
        }
    }
    
    // must be decimal
    struct Decimal: LivrRule {
        static var name = "decimal"
        var errorCode = "NOT_DECIMAL"
        
        init() {}
        
        func validate(value: Any?) -> (LivrRule.ErrorCode?, LivrRule.UpdatedValue?) {
            guard value as? Double != nil else {
                if let stringValue = value as? String {
                    if stringValue.isEmpty {
                        return (nil, nil)
                    } else if let intValue = Int(stringValue) {
                        return (nil, DecimalNum(intValue) as AnyObject)
                    } else if let doubleValue = Double(stringValue) {
                        return (nil, doubleValue as AnyObject)
                    }
                }
                return (errorCode, nil)
            }
            return (nil, nil)
        }
    }
}
