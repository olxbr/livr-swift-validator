//
//  Utils.swift
//  Livr
//
//  Created by Felipe Lefèvre Marino on 9/25/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

import Foundation

public struct Utils {
    
    public static func isPrimitive(_ value: Any) -> Bool{
        return value is String || value is NSNumber || value is Bool
    }
    
    public static func hasNoValue(_ value: Any?) -> Bool {
        if value == nil || value is NSNull { return true }
        if let value = value as? String, value.isEmpty { return true }
        return false
    }
    
    public static func isNumber(_ value: Any) -> Bool {
        return value is NSNumber
    }
    
    public static func isString(_ value: Any) -> Bool {
        return value is String
    }
    
    public static func canBeCoercedToNumber(_ value: Any) -> Bool {
        let string = String(describing: value)
        return Double(string) != nil
    }
    
    public static func isList(_ value: Any) -> Bool {
        return value is Array<Any>
    }

    /// JSON booleans and Swift booleans are NSNumbers of their own class, the numbers 0 and 1 are not
    private static let booleanType = type(of: NSNumber(value: true))

    public static func isBoolean(_ value: Any) -> Bool {
        guard let number = value as? NSNumber else { return false }
        return type(of: number) == booleanType
    }

    /// The string form of a primitive value (LIVR 2.5): a boolean is "true" or "false", an integral
    /// number has no decimal point, another number is the shortest decimal without an exponent.
    /// nil for objects, lists and nil.
    public static func stringForm(_ value: Any?) -> String? {
        if let string = value as? String { return string }
        guard let number = value as? NSNumber else { return nil }
        if isBoolean(number) { return number.boolValue ? "true" : "false" }
        if let integer = number as? Int64 { return String(integer) }
        return decimalString(number.doubleValue)
    }

    /// "\(double)" is the shortest decimal that reads back as the same double, but it can have an exponent
    private static func decimalString(_ double: Double) -> String {
        let description = "\(double)"
        guard double.isFinite, let exponentIndex = description.firstIndex(of: "e"),
            let exponent = Int(description[description.index(after: exponentIndex)...]) else {

            return description.hasSuffix(".0") ? String(description.dropLast(2)) : description
        }
        var mantissa = String(description[..<exponentIndex])
        let sign = mantissa.hasPrefix("-") ? "-" : ""
        if !sign.isEmpty { mantissa.removeFirst() }
        let parts = mantissa.split(separator: ".", omittingEmptySubsequences: false)
        let fraction = parts.count > 1 && parts[1] != "0" ? String(parts[1]) : ""
        let digits = String(parts[0]) + fraction
        let pointPosition = parts[0].count + exponent

        if pointPosition <= 0 {
            return sign + "0." + String(repeating: "0", count: -pointPosition) + digits
        } else if pointPosition >= digits.count {
            return sign + digits + String(repeating: "0", count: pointPosition - digits.count)
        }
        let index = digits.index(digits.startIndex, offsetBy: pointPosition)
        return sign + digits[..<index] + "." + digits[index...]
    }

    /// LIVR spreads a JSON list into the arguments of a rule: the arguments of the LIVR 2.5 rules. A rule
    /// without arguments ("rule") has none; {"rule": null} is one null argument, a schema error for them.
    /// The LIVR 2.0 rules and custom rules get their arguments as they are.
    static func argumentsList(_ arguments: Any?) -> [Any] {
        guard let arguments = arguments else { return [] }
        return arguments as? [Any] ?? [arguments]
    }

    /// Strings are compared code point by code point, without Unicode normalization (LIVR 2.5):
    /// Swift's == treats canonically equivalent strings, "\u{E9}" and "e\u{301}", as equal
    static func isSameString(_ first: String, _ second: String) -> Bool {
        return first.utf8.elementsEqual(second.utf8)
    }

    /// eq and one_of: the string forms are equal, so true equals "true" (LIVR 2.5), or the descriptions
    /// are, as LIVR 2.0 compared them (true and "1"), so data that passed in 2.0 still passes
    static func isEqualForEqAndOneOf(_ value: Any, _ argument: Any) -> Bool {
        guard let valueForm = stringForm(value), let argumentForm = stringForm(argument) else { return false }
        if isSameString(valueForm, argumentForm) { return true }
        // the description of a string is the string
        if value is String && argument is String { return false }
        return isSameString(description2_0(value), description2_0(argument))
    }

    /// the string that LIVR 2.0 compared: the description, where a boolean of JSON is "1" or "0" (as
    /// on Apple platforms, also on the others)
    private static func description2_0(_ value: Any) -> String {
        if isBoolean(value), let number = value as? NSNumber { return number.boolValue ? "1" : "0" }
        return String(describing: value)
    }

    /// a number, or a string in the grammar of the decimal rule (LIVR 2.5: numbers and strings are
    /// interchangeable in the arguments of the new rules)
    static func numberArgument(_ argument: Any?) -> Double? {
        guard let argument = argument, !isBoolean(argument) else { return nil }
        if let number = argument as? NSNumber { return number.doubleValue }
        if let string = argument as? String, isDecimal(string) { return Double(string) }
        return nil
    }
    
    static func nonNegativeInteger(_ argument: Any?) -> Int? {
        guard let number = numberArgument(argument), number >= 0, number == number.rounded(), number < 1e15 else { return nil }
        return Int(number)
    }
    
    /// the grammar of the decimal rule: -?[0-9]+(\.[0-9]+)?
    static func isDecimal(_ string: String) -> Bool {
        var utf8 = Substring(string).utf8
        if utf8.first == 0x2D { utf8 = utf8.dropFirst() }
        let parts = utf8.split(separator: 0x2E, maxSplits: 1, omittingEmptySubsequences: false)
        return parts.count <= 2 && parts.allSatisfy { isDigits($0) }
    }

    /// a string, or a number in its string form, but not a boolean
    static func stringArgument(_ argument: Any?) -> String? {
        guard let argument = argument, !isBoolean(argument) else { return nil }
        return stringForm(argument)
    }

    // ASCII character classes of the LIVR 2.5 grammars

    static func isDigit(_ character: UInt8) -> Bool {
        return character >= 0x30 && character <= 0x39
    }

    static func isHex(_ character: UInt8) -> Bool {
        return isDigit(character) || (character >= 0x41 && character <= 0x46) || (character >= 0x61 && character <= 0x66)
    }

    static func isLetter(_ character: UInt8) -> Bool {
        return (character >= 0x41 && character <= 0x5A) || (character >= 0x61 && character <= 0x7A)
    }

    static func isDigits<S: Collection>(_ string: S) -> Bool where S.Element == UInt8 {
        return !string.isEmpty && string.allSatisfy(isDigit)
    }

    static func isDigits(_ string: String) -> Bool {
        return isDigits(string.utf8)
    }

    static func isHex<S: Collection>(_ string: S) -> Bool where S.Element == UInt8 {
        return !string.isEmpty && string.allSatisfy(isHex)
    }
}

/// A string that is equal to another one, and hashed, code point by code point: Swift's String treats
/// canonically equivalent strings as equal, LIVR 2.5 does not normalize
struct ExactString: Hashable {
    private let utf8: [UInt8]

    init(_ string: String) {
        utf8 = Array(string.utf8)
    }
}
