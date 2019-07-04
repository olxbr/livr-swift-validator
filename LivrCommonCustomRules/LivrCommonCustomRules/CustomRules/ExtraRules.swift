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
    
    struct GreatherThanOrEqualToField: LivrRule, PreDefinedRule {
        static var name = "greater_eq_than_field"
        var errorCode: LIVR.ErrorCode = .fieldsNotEqual
        var arguments: Any?
        var otherFieldValue: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (LIVR.ErrorCode.format.rawValue, nil) }
                
                if let otherFieldValue = otherFieldValue, String(describing: value) == String(describing: otherFieldValue) {
                    return (nil, nil)
                }
                return (errorCode.rawValue, nil)
            }
            return (nil, nil)
        }
    }
}
