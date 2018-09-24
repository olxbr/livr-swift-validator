//
//  LivrRuleProtocol.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/18/18.
//

protocol LivrRule {
    static var name: String {get}
    var errorCode: String {get}
    
    typealias ErrorCode = String
    typealias UpdatedValue = AnyObject
    func validate(value: Any?) -> (ErrorCode?, UpdatedValue?)
}
