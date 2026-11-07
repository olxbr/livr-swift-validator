//
//  LIVR.swift
//  Pods-LivrDemo
//
//  Created by Felipe Lefèvre Marino on 9/18/18.
//

import Foundation

typealias LivrRulesDict = [String: LivrRule]

public struct LIVR {
    
    static var defaultRules: LivrRulesDict = rulesOfLIVR20.merging(rulesOfLIVR25) { $1 }
    
    private static let rulesOfLIVR20: LivrRulesDict = [CommonRules.Required.name: CommonRules.Required(),
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
    
    /// the rules added in LIVR 2.5
    private static let rulesOfLIVR25: LivrRulesDict = [NumericRules.Boolean.name: NumericRules.Boolean(),
                                                       NumericRules.MaxDecimals.name: NumericRules.MaxDecimals(),
                                                       
                                                       StringRules.NotOneOf.name: StringRules.NotOneOf(),
                                                       StringRules.Digits.name: StringRules.Digits(),
                                                       StringRules.StartsWith.name: StringRules.StartsWith(),
                                                       StringRules.EndsWith.name: StringRules.EndsWith(),
                                                       StringRules.Contains.name: StringRules.Contains(),
                                                       
                                                       SpecialRules.ISODateTime.name: SpecialRules.ISODateTime(),
                                                       SpecialRules.ISOTime.name: SpecialRules.ISOTime(),
                                                       
                                                       CommonRules.RequiredIf.name: CommonRules.RequiredIf(),
                                                       CommonRules.ListLength.name: CommonRules.ListLength(),
                                                       CommonRules.Unique.name: CommonRules.Unique(),
                                                       
                                                       MetaRules.When.name: MetaRules.When(),
                                                       MetaRules.Values.name: MetaRules.Values(),
                                                       MetaRules.Keys.name: MetaRules.Keys(),
                                                       MetaRules.AnyValue.name: MetaRules.AnyValue(),
                                                       
                                                       ModifiersRules.Split.name: ModifiersRules.Split(),
                                                       
                                                       FormatRules.UUID.name: FormatRules.UUID(),
                                                       FormatRules.IP.name: FormatRules.IP(),
                                                       FormatRules.CIDR.name: FormatRules.CIDR(),
                                                       FormatRules.Hostname.name: FormatRules.Hostname(),
                                                       FormatRules.Base64.name: FormatRules.Base64(),
                                                       FormatRules.Hex.name: FormatRules.Hex(),
                                                       FormatRules.Digest.name: FormatRules.Digest(),
                                                       FormatRules.MongoId.name: FormatRules.MongoId(),
                                                       FormatRules.HexColor.name: FormatRules.HexColor(),
                                                       FormatRules.MAC.name: FormatRules.MAC(),
                                                       FormatRules.E164.name: FormatRules.E164(),
                                                       FormatRules.Semver.name: FormatRules.Semver(),
                                                       FormatRules.JWT.name: FormatRules.JWT(),
                                                       FormatRules.Luhn.name: FormatRules.Luhn(),
                                                       FormatRules.CreditCard.name: FormatRules.CreditCard(),
                                                       FormatRules.IBAN.name: FormatRules.IBAN()]
    
    /// the names of the rules added in LIVR 2.5
    static let namesOfLIVR25Rules = Set(rulesOfLIVR25.keys)
    
    /// The current time for the bounds "today", "yesterday" and "tomorrow" of iso_date and iso_datetime,
    /// whose dates are taken in UTC. The system time by default; tests can fix it: `LIVR.now = { fixedDate }`.
    public static var now: () -> Date = { Date() }
    
    
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
        fieldsNotEqual = "FIELDS_NOT_EQUAL",
        
        // LIVR 2.5
        notBoolean = "NOT_BOOLEAN",
        tooManyDecimals = "TOO_MANY_DECIMALS",
        notDigits = "NOT_DIGITS",
        dateTooEarly = "DATE_TOO_EARLY",
        dateTooLate = "DATE_TOO_LATE",
        datetimeTooEarly = "DATETIME_TOO_EARLY",
        datetimeTooLate = "DATETIME_TOO_LATE",
        timeTooEarly = "TIME_TOO_EARLY",
        timeTooLate = "TIME_TOO_LATE",
        wrongDatetime = "WRONG_DATETIME",
        wrongTime = "WRONG_TIME",
        wrongKey = "WRONG_KEY",
        tooFewItems = "TOO_FEW_ITEMS",
        tooManyItems = "TOO_MANY_ITEMS",
        notUniqueItems = "NOT_UNIQUE_ITEMS",
        wrongUuid = "WRONG_UUID",
        wrongIp = "WRONG_IP",
        wrongCidr = "WRONG_CIDR",
        wrongHostname = "WRONG_HOSTNAME",
        wrongBase64 = "WRONG_BASE64",
        wrongHex = "WRONG_HEX",
        wrongDigest = "WRONG_DIGEST",
        wrongMongoId = "WRONG_MONGO_ID",
        wrongHexColor = "WRONG_HEX_COLOR",
        wrongMac = "WRONG_MAC",
        wrongE164 = "WRONG_E164",
        wrongSemver = "WRONG_SEMVER",
        wrongJwt = "WRONG_JWT",
        wrongChecksum = "WRONG_CHECKSUM",
        wrongCreditCardNumber = "WRONG_CREDIT_CARD_NUMBER",
        wrongIban = "WRONG_IBAN"
    }
}
