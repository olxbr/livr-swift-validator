//
//  AdultAge.swift
//  LivrTests
//
//  Created by Felipe Lefèvre Marino on 10/13/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

@testable import Livr

struct AdultAge: CustomRule {
    var name: String = "adult_age"
    var rules: Any?
    var arguments: Any?
    var errorCode: LIVR.ErrorCode = .format
    var customErrorCode: String? = "WRONG_AGE"
    
    init() {}
    
    func validate(value: Any?) -> (Errors?, UpdatedValue?) {
        guard !Utils.hasNoValue(value) else { return (buildError(inputErrors: customErrorCode), nil) }
        if let value = value {
            guard Utils.isPrimitive(value) else { return (buildError(inputErrors: customErrorCode), nil) }
            
            if let valueAsDouble = value as? Double {
                return validate(valueAsDouble)
            } else if let valueAsString = value as? String,
                let valueAsDouble = Double(valueAsString) {
                
                return validate(valueAsDouble)
            }
        }
        return (nil, nil)
    }
    
    private func validate(_ valueAsDouble: Double) -> (Errors?, UpdatedValue?) {
        if isAnAdult(age: valueAsDouble) {
            return (nil, nil)
        }
        return (buildError(inputErrors: errorCode.rawValue), nil)
    }
    
    private func isAnAdult(age: Double) -> Bool {
        return age >= 18.0
    }
}
