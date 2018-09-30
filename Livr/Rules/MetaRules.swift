//
//  MetaRules.swift
//  Livr
//
//  Created by Felipe Lefèvre Marino on 9/29/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

struct MetaRules {
    
    struct NestedObject: LivrRule {
        static var name: String = "nested_object"
        var errorCode: ErrorCode = "FORMAT_ERROR"
        var arguments: Any?
        var updatedValue: UpdatedValue?
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            guard let validationRules = arguments as? JSON else { return (String.formatErrorCode, nil) }
            if Utils.hasNoValue(value) { return (nil, nil) }
            
            if !(value is JSON) { return (String.formatErrorCode, nil) }
            
            var validator = LIVR.validator(validationRules: validationRules)
            
            var output: JSON?
            do {
                output = try validator.validate(data: value as! JSON)
            } catch {
                return (errorCode, nil)
            }
            
            if let output = output {
                return (nil, output as AnyObject)
            }
            return (validator.errors, nil)
        }
    }
    
    struct VariableObject: LivrRule {
        static var name: String = "variable_object"
        var errorCode: ErrorCode = "FORMAT_ERROR"
        var arguments: Any?
        var updatedValue: UpdatedValue?
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            guard let variableObjectRules = arguments as? [Any], variableObjectRules.count > 1 else { return (String.formatErrorCode, nil) }
            if Utils.hasNoValue(value) { return (nil, nil) }
            
            if !(value is JSON) { return (String.formatErrorCode, nil) }
            
            guard let validationForEachKeyFieldValue = variableObjectRules[1] as? JSON,
                let keyField = variableObjectRules.first as? String,
                let valueAsJson = value as? JSON,
                let keyFieldValue = valueAsJson[keyField] as? String,
                let validationRules = validationForEachKeyFieldValue[keyFieldValue] as? JSON else {
                    
                return (String.formatErrorCode, nil)
            }
                
            var validator = LIVR.validator(validationRules: validationRules)
            
            var output: JSON?
            do {
                output = try validator.validate(data: value as! JSON)
            } catch {
                return (errorCode, nil)
            }
            
            if let output = output {
                return (nil, output as AnyObject)
            }
            return (validator.errors, nil)
        }
    }
}
