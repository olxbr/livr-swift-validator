//
//  LivrRuleProtocol.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/18/18.
//

protocol LivrRule {
    static var name: String {get}
    var errorCode: String {get}
    var arguments: Any? {get set}
    
    typealias ErrorCode = String
    typealias UpdatedValue = AnyObject
    func validate(value: Any?) -> (ErrorCode?, UpdatedValue?)
}

extension String {
    static let formatErrorCode = "FORMAT_ERROR"
    static let tooShortErrorCode = "TOO_SHORT"
    static let tooLongErrorCode = "TOO_LONG"
}
