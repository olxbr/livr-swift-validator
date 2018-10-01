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
    
    struct ListOf: LivrRule {
        static var name: String = "list_of"
        var errorCode: ErrorCode = ""
        var arguments: Any?
        var updatedValue: UpdatedValue?
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            
            if let value = value {
                if !Utils.isList(value) { return (String.formatErrorCode, nil) }
                guard value as? [[Any]] == nil || (value as? [Any])?.count == 0 else { return (String.formatErrorCode, nil) }
                
                var errors: [Any]?
                var output: [Any]?
                
                if let listOfValues = value as? [Any] {
                    for value in listOfValues {
                        
                        let errorAndUpdatedValue = Validator.validate(value: value, validationRules: arguments)
                        if let optionalError = errorAndUpdatedValue.0, let error = optionalError {
                            errors == nil ? errors = [] : ()
                            errors?.append(error as Any)
                        } else if errors != nil {
                            errors?.append(NSNull())
                        } else if errors == nil {
                            output == nil ? output = [] : ()
                            output?.append(errorAndUpdatedValue.1 ?? value)
                        }
                    }
                    
                    if errors != nil {
                        return (errors, nil)
                    }
                    return (nil, (output ?? value) as AnyObject)
                }
            }
            
            return (nil, nil)
        }
    }
    
    struct ListOfObjects: LivrRule {
        static var name: String = "list_of_objects"
        var errorCode: ErrorCode = ""
        var arguments: Any?
        var updatedValue: UpdatedValue?
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            
            if let value = value {
                if !Utils.isList(value) { return (String.formatErrorCode, nil) }
                guard value as? [[Any]] == nil || (value as? [Any])?.count == 0 else { return (String.formatErrorCode, nil) }
                guard let validationRules = arguments as? JSON else { return (String.formatErrorCode, nil) }

                var errors: [Any]?
                var output: [Any]?
                
                if let listOfValues = value as? [Any] {
                    for value in listOfValues {
                        
                        if !(value is JSON) {
                            errors == nil ? errors = [] : ()
                            errors?.append(String.formatErrorCode)
                            continue
                        }
                        
                        var validator = LIVR.validator(validationRules: validationRules)
                        
                        var validatorOutput: JSON?
                        do {
                            validatorOutput = try validator.validate(data: value as! JSON)
                        } catch {
                            return (errorCode, nil)
                        }
                        
                        if let validationErrors = validator.errors {
                            errors == nil ? errors = [] : ()
                            errors?.append(validationErrors as Any)
                        } else if errors != nil {
                            errors?.append(NSNull())
                        } else if errors == nil {
                            output == nil ? output = [] : ()
                            output?.append(validatorOutput as Any)
                        }
                    }
                    
                    if errors != nil {
                        return (errors, nil)
                    }
                    return (nil, (output ?? value) as AnyObject)
                }
            }
            
            return (nil, nil)
        }
    }
}
