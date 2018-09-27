//
//  LIVR.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/18/18.
//

typealias LivrRulesDict = [String: LivrRule]

struct LIVR {
    
    static var defaultRules: LivrRulesDict = [CommonRules.Required.name: CommonRules.Required(),
                                              CommonRules.NotEmpty.name: CommonRules.NotEmpty(),
                                              NumericRules.Integer.name: NumericRules.Integer(),
                                              NumericRules.Decimal.name: NumericRules.Decimal(),
                                              NumericRules.PositiveInteger.name: NumericRules.PositiveInteger(),
                                              NumericRules.PositiveDecimal.name: NumericRules.PositiveDecimal(),
                                              StringRules.String.name: StringRules.String(),
                                              SpecialRules.URL.name: SpecialRules.URL(),
                                              SpecialRules.Email.name: SpecialRules.Email(),
                                              SpecialRules.ISODate.name: SpecialRules.ISODate(),
                                              CommonRules.NotEmptyList.name: CommonRules.NotEmptyList(),
                                              CommonRules.AnyObject.name: CommonRules.AnyObject(),
                                              StringRules.Eq.name: StringRules.Eq()]
    
    public static func validator(validationRules: JSON) -> Validator {
        var validator = Validator(validationRules: validationRules)
        validator.register(defaultRules)
        return validator
    }
}
