//
//  SpecialRules.swift
//  Livr
//
//  Created by Felipe Lefèvre Marino on 9/25/18.
//  Copyright © 2018 Felipe Marino. All rights reserved.
//

import Foundation

typealias URLType = URL

public protocol RuleThatCompareFields: LivrRule {
    var otherFieldValue: Any? { get set }
}

struct SpecialRules {
    
    // must be a valid URL
    struct URL: LivrRule, PreDefinedRule {
        static var name = "url"
        var errorCode: LIVR.ErrorCode = .wrongUrl
        let regex = "^(?:(?:http|https|HTTP|HTTPS)://)(?:\\S+(?::\\S*)?@)?(?:(?:(?:[1-9]\\d?|1\\d\\d|2[0-1]\\d|22[0-3])(?:\\.(?:1?\\d{1,2}|2[0-4]\\d|25[0-5])){2}(?:\\.(?:[0-9]\\d?|1\\d\\d|2[0-4]\\d|25[0-4]))|(?:(?:[a-z\\u00a1-\\uffff0-9]-*)*[a-z\\u00a1-\\uffff0-9]+)(?:\\.(?:[a-z\\u00a1-\\uffff0-9]-*)*[a-z\\u00a1-\\uffff0-9]+)*(?:\\.(?:[a-z\\u00a1-\\uffff]{2,})))\\.?|localhost)(?::\\d{2,5})?(?:[/?#]\\S*)?$"
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (LIVR.ErrorCode.format.rawValue, nil) }
                
                if let stringValue = value as? String,
                    stringValue.count < 2083, stringValue.matches(regex: regex) {
                        return (nil, nil)
                }
                return (errorCode.rawValue, nil)
            }
            return (nil, nil)
        }
    }
    
    // must be a valid email
    struct Email: LivrRule, PreDefinedRule {
        static var name = "email"
        var errorCode: LIVR.ErrorCode = .wrongEmail
        // One "@" only, and no "_" in the domain: a quoted local part cannot contain "@",
        // the domain cannot contain "_" or "@".
        let regex = "(?:[^<>()\\[\\]\\\\.,;:\\s@\"]+(?:\\.[^<>()\\[\\]\\\\.,;:\\s@\"]+)*|\"[^@\\n\\r\\u2028\\u2029]+\")"
            + "@(?:\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\]|(?:[a-zA-Z\\-0-9]+\\.)+[a-zA-Z]{2,})"
        var arguments: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (LIVR.ErrorCode.format.rawValue, nil) }
                
                if let stringValue = value as? String, stringValue.matches(regex: regex) {
                    return (nil, nil)
                }
                return (errorCode.rawValue, nil)
            }
            return (nil, nil)
        }
    }
    
    // must be a valid date, YYYY-MM-DD, with optional bounds (LIVR 2.5): { "iso_date": { "min": "today" } }
    struct ISODate: LivrRule, PreDefinedRule {
        static var name = "iso_date"
        var errorCode: LIVR.ErrorCode = .wrongDate
        var arguments: Any?
        private var min: DateBound?
        private var max: DateBound?
        
        init() {}
        
        mutating func prepare() throws {
            // {"iso_date": null} is the plain iso_date, as LIVR 2.0 ignored the arguments of iso_date
            let argumentsList = Utils.argumentsList(arguments)
            let isNullArgument = argumentsList.count == 1 && argumentsList[0] is NSNull
            let options = try DateTime.options(isNullArgument ? nil : arguments, of: ISODate.name)
            min = try options.min.map { try DateBound($0, of: ISODate.name) }
            max = try options.max.map { try DateBound($0, of: ISODate.name) }
            
            // no value could pass, when both bounds are dates or both are relative
            if let min = min, let max = max, min.isRelative == max.isRelative, min.day(today: 0) > max.day(today: 0) {
                throw RuleGenerator.wrongArguments(ISODate.name, arguments)
            }
        }
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (LIVR.ErrorCode.format.rawValue, nil) }
                
                guard let stringValue = value as? String, let day = DateTime.day(Array(stringValue.utf8)[...]) else {
                    return (errorCode.rawValue, nil)
                }
                if min != nil || max != nil {
                    let today = DateTime.today()
                    if let min = min, day < min.day(today: today) { return (LIVR.ErrorCode.dateTooEarly.rawValue, nil) }
                    if let max = max, day > max.day(today: today) { return (LIVR.ErrorCode.dateTooLate.rawValue, nil) }
                }
            }
            return (nil, nil)
        }
    }
    
    /// a date and a time with an offset; the output is the instant in UTC, YYYY-MM-DDTHH:MM:SS.sssZ
    struct ISODateTime: LivrRule, PreDefinedRule {
        static var name = "iso_datetime"
        var errorCode: LIVR.ErrorCode = .wrongDatetime
        var arguments: Any?
        private var min: DatetimeBound?
        private var max: DatetimeBound?
        
        init() {}
        
        mutating func prepare() throws {
            let options = try DateTime.options(arguments, of: ISODateTime.name)
            min = try options.min.map { try DatetimeBound($0, of: ISODateTime.name) }
            max = try options.max.map { try DatetimeBound($0, of: ISODateTime.name) }
            
            if let min = min, let max = max, min.isRelative == max.isRelative,
                min.milliseconds(asMax: false, today: 0) > max.milliseconds(asMax: true, today: 0) {
                throw RuleGenerator.wrongArguments(ISODateTime.name, arguments)
            }
        }
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            guard let value = value, Utils.isPrimitive(value) else { return (LIVR.ErrorCode.format.rawValue, nil) }
            
            // the UTC instant must be writable in the output form
            guard let stringValue = value as? String, let milliseconds = DateTime.milliseconds(Array(stringValue.utf8)),
                milliseconds >= DateTime.firstMillisecond, milliseconds < DateTime.lastMillisecond else {
                return (errorCode.rawValue, nil)
            }
            if min != nil || max != nil {
                let today = DateTime.today()
                if let min = min, milliseconds < min.milliseconds(asMax: false, today: today) {
                    return (LIVR.ErrorCode.datetimeTooEarly.rawValue, nil)
                }
                if let max = max, milliseconds > max.milliseconds(asMax: true, today: today) {
                    return (LIVR.ErrorCode.datetimeTooLate.rawValue, nil)
                }
            }
            return (nil, DateTime.utcString(milliseconds) as AnyObject)
        }
    }
    
    /// a time of day, HH:MM[:SS[.fraction]]; min later than max is a range over midnight
    struct ISOTime: LivrRule, PreDefinedRule {
        static var name = "iso_time"
        var errorCode: LIVR.ErrorCode = .wrongTime
        var arguments: Any?
        private var min: Int64?
        private var max: Int64?
        
        init() {}
        
        mutating func prepare() throws {
            let arguments = self.arguments
            let options = try DateTime.options(arguments, of: ISOTime.name)
            let time = { (bound: String) throws -> Int64 in
                guard let nanoseconds = DateTime.nanoseconds(Array(bound.utf8)[...]) else {
                    throw RuleGenerator.wrongArguments(ISOTime.name, arguments)
                }
                return nanoseconds
            }
            min = try options.min.map(time)
            max = try options.max.map(time)
        }
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            guard let value = value, Utils.isPrimitive(value) else { return (LIVR.ErrorCode.format.rawValue, nil) }
            guard let stringValue = value as? String, let time = DateTime.nanoseconds(Array(stringValue.utf8)[...]) else {
                return (errorCode.rawValue, nil)
            }
            
            if let min = min, let max = max, min > max {
                // over midnight: a time in the gap gets the error of the nearer bound
                if time >= min || time <= max { return (nil, nil) }
                return time - max < min - time ? (LIVR.ErrorCode.timeTooLate.rawValue, nil) : (LIVR.ErrorCode.timeTooEarly.rawValue, nil)
            }
            if let min = min, time < min { return (LIVR.ErrorCode.timeTooEarly.rawValue, nil) }
            if let max = max, time > max { return (LIVR.ErrorCode.timeTooLate.rawValue, nil) }
            return (nil, nil)
        }
    }
    
    struct EqualToField: LivrRule, PreDefinedRule, RuleThatCompareFields {
        static var name = "equal_to_field"
        var errorCode: LIVR.ErrorCode = .fieldsNotEqual
        var arguments: Any?
        var otherFieldValue: Any?
        
        init() {}
        
        func validate(value: Any?) -> (Errors?, UpdatedValue?) {
            if Utils.hasNoValue(value) { return (nil, nil) }
            if let value = value {
                if !Utils.isPrimitive(value) { return (LIVR.ErrorCode.format.rawValue, nil) }
                
                if let otherFieldValue = otherFieldValue, String(describing: value) == String(describing: otherFieldValue) {
                    return (nil, nil)
                }
                return (errorCode.rawValue, nil)
            }
            return (nil, nil)
        }
    }
}

// MARK: - Dates and times (LIVR 2.5)

/// a bound of iso_date: a date, or "today", "yesterday", "tomorrow" in UTC
private enum DateBound {
    case date(Int), relative(Int)
    
    init(_ bound: String, of ruleName: String) throws {
        if let offset = DateTime.relativeDays[bound] {
            self = .relative(offset)
        } else if let day = DateTime.day(Array(bound.utf8)[...]) {
            self = .date(day)
        } else {
            throw Validator.ErrorType.wrongArguments(rule: ruleName, reason: "wrong bound " + bound)
        }
    }
    
    var isRelative: Bool {
        if case .relative = self { return true }
        return false
    }
    
    func day(today: Int) -> Int {
        switch self {
        case .date(let day): return day
        case .relative(let offset): return today + offset
        }
    }
}

/// a bound of iso_datetime: a datetime, or a date (or a relative date) from the start of the day as
/// min, to the end of the day as max
private enum DatetimeBound {
    case instant(Int64), date(DateBound)
    
    init(_ bound: String, of ruleName: String) throws {
        if let milliseconds = DateTime.milliseconds(Array(bound.utf8)) {
            self = .instant(milliseconds)
        } else {
            self = .date(try DateBound(bound, of: ruleName))
        }
    }
    
    var isRelative: Bool {
        if case .date(let date) = self { return date.isRelative }
        return false
    }
    
    func milliseconds(asMax: Bool, today: Int) -> Int64 {
        switch self {
        case .instant(let milliseconds):
            return milliseconds
        case .date(let date):
            let start = Int64(date.day(today: today)) * DateTime.millisecondsPerDay
            return asMax ? start + DateTime.millisecondsPerDay - 1 : start
        }
    }
}

/// Parsing and formatting without DateFormatter: the grammars are ASCII, the calendar is the proleptic
/// Gregorian one, and the time zone is always UTC.
private struct DateTime {
    static let millisecondsPerDay: Int64 = 86_400_000
    static let relativeDays = ["yesterday": -1, "today": 0, "tomorrow": 1]
    /// the instants that can be written as YYYY-MM-DDTHH:MM:SS.sssZ
    static let firstMillisecond = Int64(daysFromCivil(year: 0, month: 1, day: 1)) * millisecondsPerDay
    static let lastMillisecond = Int64(daysFromCivil(year: 10000, month: 1, day: 1)) * millisecondsPerDay
    
    /// the current date in UTC, as days since 1970-01-01
    static func today() -> Int {
        return Int((LIVR.now().timeIntervalSince1970 / 86_400).rounded(.down))
    }
    
    /// nothing, or an options object with min and max first; the arguments after it are ignored
    static func options(_ arguments: Any?, of ruleName: String) throws -> (min: String?, max: String?) {
        let arguments = Utils.argumentsList(arguments)
        guard let first = arguments.first else { return (nil, nil) }
        guard let options = first as? [String: Any?], options.keys.allSatisfy({ $0 == "min" || $0 == "max" }),
            options.values.allSatisfy({ $0 is String }) else {
            throw RuleGenerator.wrongArguments(ruleName, arguments)
        }
        return (options["min"] as? String, options["max"] as? String)
    }
    
    private static func number(_ digits: ArraySlice<UInt8>) -> Int? {
        guard Utils.isDigits(digits) else { return nil }
        return digits.reduce(0) { $0 * 10 + Int($1 - 0x30) }
    }
    
    private static func number(_ bytes: ArraySlice<UInt8>, at index: Int, upTo maximum: Int) -> Int? {
        let start = bytes.startIndex + index
        guard start + 2 <= bytes.endIndex, let number = number(bytes[start..<start + 2]), number <= maximum else { return nil }
        return number
    }
    
    /// YYYY-MM-DD, a valid calendar date, as days since 1970-01-01
    static func day(_ bytes: ArraySlice<UInt8>) -> Int? {
        let start = bytes.startIndex
        guard bytes.count == 10, bytes[start + 4] == 0x2D, bytes[start + 7] == 0x2D,
            let year = number(bytes[start..<start + 4]), let month = number(bytes, at: 5, upTo: 12),
            let day = number(bytes, at: 8, upTo: 31), month >= 1, day >= 1 else { return nil }
        
        let isLeapYear = year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
        let daysInMonth = [31, isLeapYear ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month - 1]
        guard day <= daysInMonth else { return nil }
        return daysFromCivil(year: year, month: month, day: day)
    }
    
    /// HH:MM[:SS[.1-9 digits]] as nanoseconds since midnight
    static func nanoseconds(_ bytes: ArraySlice<UInt8>) -> Int64? {
        let start = bytes.startIndex
        guard bytes.count >= 5, bytes[start + 2] == 0x3A,
            let hours = number(bytes, at: 0, upTo: 23), let minutes = number(bytes, at: 3, upTo: 59) else { return nil }
        
        var nanoseconds = Int64(hours * 60 + minutes) * 60 * 1_000_000_000
        if bytes.count == 5 { return nanoseconds }
        guard bytes.count >= 8, bytes[start + 5] == 0x3A, let seconds = number(bytes, at: 6, upTo: 59) else { return nil }
        nanoseconds += Int64(seconds) * 1_000_000_000
        if bytes.count == 8 { return nanoseconds }
        
        let fraction = bytes[(start + 9)...]
        guard bytes[start + 8] == 0x2E, fraction.count <= 9, let digits = number(fraction) else { return nil }
        var multiplier: Int64 = 1
        for _ in fraction.count..<9 { multiplier *= 10 }
        return nanoseconds + Int64(digits) * multiplier
    }
    
    /// YYYY-MM-DD "T" HH:MM[:SS[.1-9 digits]] ("Z" / ("+" / "-") HH:MM) as milliseconds since
    /// 1970-01-01T00:00Z, the fraction cut to milliseconds
    static func milliseconds(_ bytes: [UInt8]) -> Int64? {
        guard bytes.count > 16, bytes[10] == 0x54, let day = day(bytes[0..<10]) else { return nil }
        
        var offset: Int64 = 0
        var timeEnd = bytes.count - 1
        if bytes[timeEnd] != 0x5A {
            timeEnd = bytes.count - 6
            guard timeEnd > 10, bytes[timeEnd] == 0x2B || bytes[timeEnd] == 0x2D, bytes[timeEnd + 3] == 0x3A,
                let hours = number(bytes[...], at: timeEnd + 1, upTo: 23),
                let minutes = number(bytes[...], at: timeEnd + 4, upTo: 59) else { return nil }
            offset = Int64(hours * 60 + minutes) * 60_000 * (bytes[timeEnd] == 0x2B ? 1 : -1)
        }
        guard let nanoseconds = nanoseconds(bytes[11..<timeEnd]) else { return nil }
        return Int64(day) * millisecondsPerDay + nanoseconds / 1_000_000 - offset
    }
    
    /// YYYY-MM-DDTHH:MM:SS.sssZ
    static func utcString(_ milliseconds: Int64) -> String {
        let days = Int((Double(milliseconds) / Double(millisecondsPerDay)).rounded(.down))
        let time = Int(milliseconds - Int64(days) * millisecondsPerDay)
        let date = civilFromDays(days)
        
        func padded(_ number: Int, _ width: Int) -> String {
            let digits = String(number)
            return String(repeating: "0", count: max(0, width - digits.count)) + digits
        }
        return padded(date.year, 4) + "-" + padded(date.month, 2) + "-" + padded(date.day, 2)
            + "T" + padded(time / 3_600_000, 2) + ":" + padded(time / 60_000 % 60, 2) + ":" + padded(time / 1000 % 60, 2)
            + "." + padded(time % 1000, 3) + "Z"
    }
    
    // days from and to dates of the proleptic Gregorian calendar (http://howardhinnant.github.io/date_algorithms.html)
    
    static func daysFromCivil(year: Int, month: Int, day: Int) -> Int {
        let year = month <= 2 ? year - 1 : year
        let era = (year >= 0 ? year : year - 399) / 400
        let yearOfEra = year - era * 400
        let dayOfYear = (153 * (month > 2 ? month - 3 : month + 9) + 2) / 5 + day - 1
        let dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
        return era * 146_097 + dayOfEra - 719_468
    }
    
    static func civilFromDays(_ days: Int) -> (year: Int, month: Int, day: Int) {
        let days = days + 719_468
        let era = (days >= 0 ? days : days - 146_096) / 146_097
        let dayOfEra = days - era * 146_097
        let yearOfEra = (dayOfEra - dayOfEra / 1460 + dayOfEra / 36_524 - dayOfEra / 146_096) / 365
        let dayOfYear = dayOfEra - (365 * yearOfEra + yearOfEra / 4 - yearOfEra / 100)
        let monthIndex = (5 * dayOfYear + 2) / 153
        let month = monthIndex < 10 ? monthIndex + 3 : monthIndex - 9
        return (yearOfEra + era * 400 + (month <= 2 ? 1 : 0), month, dayOfYear - (153 * monthIndex + 2) / 5 + 1)
    }
}

