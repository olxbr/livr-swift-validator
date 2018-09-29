//
//  LivrRuleProtocol.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/18/18.
//

protocol LivrRule {
    static var name: String {get}
    
    typealias ErrorCode = String
    var errorCode: ErrorCode {get}
    var arguments: Any? {get set}
    
    typealias Errors = Any?
    typealias UpdatedValue = AnyObject
    func validate(value: Any?) -> (Errors?, UpdatedValue?)
}

extension String {
    static let formatErrorCode = "FORMAT_ERROR"
    static let tooShortErrorCode = "TOO_SHORT"
    static let tooLongErrorCode = "TOO_LONG"
    static let tooLowErrorCode = "TOO_LOW"
    static let tooHighErrorCode = "TOO_HIGH"
    static let notNumberErrorCode = "NOT_NUMBER"
}
