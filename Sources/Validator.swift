//
//  Validator.swift
//  Pods-Livr
//
//  Created by Felipe Lefèvre Marino on 9/14/18.
//

protocol LivrRule {
    var name: String {get}
    var errorCode: String {get}
    
    typealias ErrorCode = String
    func validate(value: Any) throws -> ErrorCode?
}

struct Common {
    
    struct Required: LivrRule {
        var name = "required"
        var errorCode = "CANNOT_BE_EMPTY"
        
        init() {}
        
        func validate(value: Any) -> ErrorCode? {
            guard let stringValue = value as? String, !stringValue.isEmpty else {
                return errorCode
            }
            return nil
        }
    }
}

enum Rule: String {
    case required
}

struct Validator {
    
    private(set) var errors: [Json]?
    
    typealias Json = [String: Any]
    mutating func validate(data: Json) -> Bool {
        
        for pairOfFieldNameAndValidationRule in data {
            let field = pairOfFieldNameAndValidationRule.key
            let validationRule = pairOfFieldNameAndValidationRule.value
            
            verify(validationRule, for: field)
        }
        
        return errors != nil
    }
    
    mutating func verify(_ validationRule: Any, for field: String) {
        if let stringRule = validationRule as? String, let rule = Rule(rawValue: stringRule), rule == .required {
            if let error = Common.Required().validate(value: stringRule) {
                errors?.append([field: error])
            }
        }
    }
    
    private func autoTrim(data: Any) -> Any {
        if var data = data as? [Json] {
            for (index, _) in data.enumerated() {
                data[index].trim()
            }
        } else if var data = data as? Json {
            return data.trim()
        }
        
        return data
    }
}
