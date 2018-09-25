//
//  SpecialRules.swift
//  Livr
//
//  Created by Felipe Lefèvre Marino on 9/25/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

typealias URLType = URL

struct SpecialRules {
    
    // must be a valid URL
    struct URL: LivrRule {
        static var name = "url"
        var errorCode = "WRONG_URL"
        
        init() {}
        
        func validate(value: Any?) -> (LivrRule.ErrorCode?, LivrRule.UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value: value) { return (.formatErrorCode, nil) }
                
                if let stringValue = value as? String,
                    stringValue.count < 2083, URLType(string: stringValue) != nil {
                        return (nil, nil)
                }
                return (errorCode, nil)
            }
            return (nil, nil)
        }
    }
    
    // must be a valid email
    struct Email: LivrRule {
        static var name = "email"
        var errorCode = "WRONG_EMAIL"
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        init() {}
        
        func validate(value: Any?) -> (LivrRule.ErrorCode?, LivrRule.UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value: value) { return (.formatErrorCode, nil) }
                
                let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
                if let stringValue = value as? String, predicate.evaluate(with: stringValue) {
                    return (nil, nil)
                }
                return (errorCode, nil)
            }
            return (nil, nil)
        }
    }
    
    // must be a valid email
    struct ISODate: LivrRule {
        static var name = "iso_date"
        var errorCode = "WRONG_DATE"
        
        init() {}
        
        func validate(value: Any?) -> (LivrRule.ErrorCode?, LivrRule.UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value: value) { return (.formatErrorCode, nil) }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                if let stringValue = value as? String, formatter.date(from: stringValue) != nil {
                    return (nil, nil)
                }
                return (errorCode, nil)
            }
            return (nil, nil)
        }
    }
}
