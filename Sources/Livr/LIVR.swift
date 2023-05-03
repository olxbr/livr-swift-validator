//
//  LIVR.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/18/18.
//

typealias LivrRulesDict = [String: LivrRule]

public struct LIVR {
    
    static var defaultRules: LivrRulesDict = [CommonRules.Required.name: CommonRules.Required(),
                                              CommonRules.NotEmpty.name: CommonRules.NotEmpty(),
                                              CommonRules.NotEmptyList.name: CommonRules.NotEmptyList(),
                                              CommonRules.AnyObject.name: CommonRules.AnyObject(),
                                              
                                              StringRules.Eq.name: StringRules.Eq(),
                                              StringRules.OneOf.name: StringRules.OneOf(),
                                              StringRules.MaxLength.name: StringRules.MaxLength(),
                                              StringRules.MinLength.name: StringRules.MinLength(),
                                              StringRules.LengthBetween.name: StringRules.LengthBetween(),
                                              StringRules.LengthEqual.name: StringRules.LengthEqual(),
                                              StringRules.Like.name: StringRules.Like(),
                                              StringRules.String.name: StringRules.String(),
                                              
                                              NumericRules.Integer.name: NumericRules.Integer(),
                                              NumericRules.Decimal.name: NumericRules.Decimal(),
                                              NumericRules.PositiveInteger.name: NumericRules.PositiveInteger(),
                                              NumericRules.PositiveDecimal.name: NumericRules.PositiveDecimal(),
                                              NumericRules.MaxNumber.name: NumericRules.MaxNumber(),
                                              NumericRules.MinNumber.name: NumericRules.MinNumber(),
                                              NumericRules.NumberBetween.name: NumericRules.NumberBetween(),
                                              
                                              SpecialRules.URL.name: SpecialRules.URL(),
                                              SpecialRules.Email.name: SpecialRules.Email(),
                                              SpecialRules.ISODate.name: SpecialRules.ISODate(),
                                              SpecialRules.EqualToField.name: SpecialRules.EqualToField(),
                                              
                                              MetaRules.NestedObject.name: MetaRules.NestedObject(),
                                              MetaRules.VariableObject.name: MetaRules.VariableObject(),
                                              MetaRules.ListOf.name: MetaRules.ListOf(),
                                              MetaRules.ListOfObjects.name: MetaRules.ListOfObjects(),
                                              MetaRules.ListOfDifferentObjects.name: MetaRules.ListOfDifferentObjects(),
                                              MetaRules.Or.name: MetaRules.Or(),
                                              
                                              ModifiersRules.ToLc.name: ModifiersRules.ToLc(),
                                              ModifiersRules.ToUc.name: ModifiersRules.ToUc(),
                                              ModifiersRules.Remove.name: ModifiersRules.Remove(),
                                              ModifiersRules.LeaveOnly.name: ModifiersRules.LeaveOnly(),
                                              ModifiersRules.Default.name: ModifiersRules.Default(),
                                              ModifiersRules.Trim.name: ModifiersRules.Trim()]
    
    
    public static func validator(validationRules: [String: Any?], isAutoTrim: Bool = true) -> Validator {
        return Validator(validationRules: validationRules, isAutoTrim: isAutoTrim)
    }
    
    public static func validator(isAutoTrim: Bool) -> Validator {
        return Validator(isAutoTrim: isAutoTrim)
    }
    
    public static func register(rule: CustomRule) {
        LIVR.defaultRules[rule.name] = rule
    }
}

public extension LIVR {
    
    enum ErrorCode: String {
        case required = "REQUIRED",
        cannotBeEmpty = "CANNOT_BE_EMPTY",
        format = "FORMAT_ERROR",
        tooShort = "TOO_SHORT",
        tooLong = "TOO_LONG",
        tooLow = "TOO_LOW",
        tooHigh = "TOO_HIGH",
        notNumber = "NOT_NUMBER",
        notInteger = "NOT_INTEGER",
        notPositiveInteger = "NOT_POSITIVE_INTEGER",
        notDecimal = "NOT_DECIMAL",
        notPositiveDecimal = "NOT_POSITIVE_DECIMAL",
        notAllowedValue = "NOT_ALLOWED_VALUE",
        wrongFormat = "WRONG_FORMAT",
        wrongEmail = "WRONG_EMAIL",
        wrongUrl = "WRONG_URL",
        wrongDate = "WRONG_DATE",
        fieldsNotEqual = "FIELDS_NOT_EQUAL"
    }
}
