//
//  FormatRules.swift
//  Livr
//
//  Format and checksum rules of LIVR 2.5.
//

import Foundation

/// A format or checksum rule: it checks the string form of a primitive value and outputs it.
/// A boolean gives the error code of the rule, an object or a list gives FORMAT_ERROR.
protocol FormatRule: PreDefinedRule {
    func isValid(_ string: [UInt8]) -> Bool
}

extension FormatRule {
    
    mutating func prepare() throws {
        try RuleGenerator.checkNoArguments(arguments, of: Self.name)
    }
    
    func validate(value: Any?) -> (Errors?, UpdatedValue?) {
        if Utils.hasNoValue(value) { return (nil, nil) }
        guard let stringForm = Utils.stringForm(value) else { return (LIVR.ErrorCode.format.rawValue, nil) }
        if Utils.isBoolean(value as Any) || !isValid(Array(stringForm.utf8)) { return (errorCode.rawValue, nil) }
        return (nil, stringForm as AnyObject)
    }
    
    /// the argument values that a rule accepts: none, or one or more of the allowed ones (only the
    /// first one for a rule that takes one argument: the others are ignored)
    func allowedArguments(_ allowed: Set<String>, takesOne: Bool = false) throws -> Set<String> {
        let arguments = Utils.argumentsList(self.arguments).prefix(takesOne ? 1 : Int.max)
        let values = arguments.compactMap { Utils.stringArgument($0) }
        guard values.count == arguments.count, Set(values).isSubset(of: allowed) else {
            throw RuleGenerator.wrongArguments(Self.name, self.arguments)
        }
        return Set(values)
    }
}

private let colon: UInt8 = 0x3A, dot: UInt8 = 0x2E, dash: UInt8 = 0x2D

private func isIPv4(_ string: ArraySlice<UInt8>) -> Bool {
    let parts = string.split(separator: dot, omittingEmptySubsequences: false)
    return parts.count == 4 && parts.allSatisfy(isOctet)
}

/// 0-255 without leading zeros
private func isOctet(_ part: ArraySlice<UInt8>) -> Bool {
    guard Utils.isDigits(part), part.count <= 3, part.count == 1 || part.first != 0x30 else { return false }
    let number: Int = part.reduce(0) { $0 * 10 + Int($1 - 0x30) }
    return number <= 255
}

private func isIPv6(_ string: ArraySlice<UInt8>) -> Bool {
    // one "::" may replace one or more groups of zeros
    var halves: [ArraySlice<UInt8>] = []
    var start = string.startIndex, index = string.startIndex
    while index < string.endIndex {
        if string[index] == colon, index + 1 < string.endIndex, string[index + 1] == colon {
            halves.append(string[start..<index])
            index += 2
            start = index
        } else {
            index += 1
        }
    }
    halves.append(string[start..<string.endIndex])
    guard halves.count <= 2 else { return false }
    
    var groups = 0
    for (halfIndex, half) in halves.enumerated() where !half.isEmpty {
        let parts = half.split(separator: colon, omittingEmptySubsequences: false)
        for (partIndex, part) in parts.enumerated() {
            // the last two groups may be an IPv4 address
            if halfIndex == halves.count - 1 && partIndex == parts.count - 1 && part.contains(dot) {
                guard isIPv4(part) else { return false }
                groups += 2
            } else {
                guard (1...4).contains(part.count), part.allSatisfy(Utils.isHex) else { return false }
                groups += 1
            }
        }
    }
    return halves.count == 2 ? groups <= 7 : groups == 8
}

private func isIP(_ string: ArraySlice<UInt8>, versions: Set<String>) -> Bool {
    return (versions.isEmpty || versions.contains("v4")) && isIPv4(string)
        || (versions.isEmpty || versions.contains("v6")) && isIPv6(string)
}

/// the Luhn mod 10 checksum is 0
private func hasLuhnChecksum(_ digits: [UInt8]) -> Bool {
    var sum = 0
    for (index, character) in digits.reversed().enumerated() {
        let digit = Int(character - 0x30)
        sum += index % 2 == 1 ? (digit * 2 > 9 ? digit * 2 - 9 : digit * 2) : digit
    }
    return sum % 10 == 0
}

/// a regular expression that matches the whole string, compiled once
private func wholeString(_ pattern: String) -> NSRegularExpression {
    return try! NSRegularExpression(pattern: "\\A(?:" + pattern + ")\\z", options: [])
}

private let semverRegex = wholeString(
    "(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)\\.(0|[1-9][0-9]*)"
        + "(?:-((?:0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*))*))?"
        + "(?:\\+([0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?")

struct FormatRules {
    
    /// RFC 9562: any version 1-8 with the variant 8, 9, a or b, the nil and the max UUID; or the given versions
    struct UUID: FormatRule {
        static var name = "uuid"
        var errorCode: LIVR.ErrorCode = .wrongUuid
        var arguments: Any?
        private var versions = Set<UInt8>()
        
        mutating func prepare() throws {
            let allowed = Set((1...8).map { "v\($0)" })
            versions = Set(try allowedArguments(allowed).map { $0.utf8.last! })
        }
        
        func isValid(_ string: [UInt8]) -> Bool {
            let dashes = [8, 13, 18, 23]
            guard string.count == 36,
                string.indices.allSatisfy({ dashes.contains($0) ? string[$0] == dash : Utils.isHex(string[$0]) }) else { return false }
            
            if versions.isEmpty {
                let hex = string.filter { $0 != dash }
                if hex.allSatisfy({ $0 == 0x30 }) || hex.allSatisfy({ $0 == 0x66 || $0 == 0x46 }) { return true }
            }
            let version = string[14], variant = string[19]
            let isVersion = versions.isEmpty ? (0x31...0x38).contains(version) : versions.contains(version)
            return isVersion && [0x38, 0x39, 0x61, 0x62, 0x41, 0x42].contains(variant)
        }
    }
    
    struct IP: FormatRule {
        static var name = "ip"
        var errorCode: LIVR.ErrorCode = .wrongIp
        var arguments: Any?
        private var versions = Set<String>()
        
        mutating func prepare() throws {
            versions = try allowedArguments(["v4", "v6"], takesOne: true)
        }
        
        func isValid(_ string: [UInt8]) -> Bool {
            return isIP(string[...], versions: versions)
        }
    }
    
    /// an ip address, "/" and a prefix length; host bits may be set
    struct CIDR: FormatRule {
        static var name = "cidr"
        var errorCode: LIVR.ErrorCode = .wrongCidr
        var arguments: Any?
        private var versions = Set<String>()
        
        mutating func prepare() throws {
            versions = try allowedArguments(["v4", "v6"], takesOne: true)
        }
        
        func isValid(_ string: [UInt8]) -> Bool {
            let parts = string.split(separator: 0x2F, omittingEmptySubsequences: false)
            guard parts.count == 2, Utils.isDigits(parts[1]), parts[1].count <= 3,
                parts[1].count == 1 || parts[1].first != 0x30 else { return false }
            
            let prefixLength = parts[1].reduce(0) { $0 * 10 + Int($1 - 0x30) }
            if (versions.isEmpty || versions.contains("v4")) && isIPv4(parts[0]) {
                return prefixLength <= 32
            }
            return (versions.isEmpty || versions.contains("v6")) && isIPv6(parts[0]) && prefixLength <= 128
        }
    }
    
    /// RFC 1123 labels separated by "."; the last label is not all digits
    struct Hostname: FormatRule {
        static var name = "hostname"
        var errorCode: LIVR.ErrorCode = .wrongHostname
        var arguments: Any?
        
        func isValid(_ string: [UInt8]) -> Bool {
            let labels = string.split(separator: dot, omittingEmptySubsequences: false)
            guard string.count <= 253, let last = labels.last, !Utils.isDigits(last) else { return false }
            return labels.allSatisfy { label in
                (1...63).contains(label.count) && label.first != dash && label.last != dash
                    && label.allSatisfy { Utils.isLetter($0) || Utils.isDigit($0) || $0 == dash }
            }
        }
    }
    
    /// RFC 4648: the standard alphabet with padding, or { "base64": "url" }, the URL-safe alphabet with optional padding
    struct Base64: FormatRule {
        static var name = "base64"
        var errorCode: LIVR.ErrorCode = .wrongBase64
        var arguments: Any?
        private var isURL = false
        
        mutating func prepare() throws {
            isURL = try allowedArguments(["url"], takesOne: true).contains("url")
        }
        
        func isValid(_ string: [UInt8]) -> Bool {
            let data = string.prefix { $0 != 0x3D }
            let padding = string.count - data.count
            let extra: Set<UInt8> = isURL ? [dash, 0x5F] : [0x2B, 0x2F]
            guard padding <= 2, string[data.count...].allSatisfy({ $0 == 0x3D }),
                data.allSatisfy({ Utils.isLetter($0) || Utils.isDigit($0) || extra.contains($0) }) else { return false }
            
            if isURL && padding == 0 { return string.count % 4 != 1 }
            return string.count % 4 == 0
        }
    }
    
    struct Hex: FormatRule {
        static var name = "hex"
        var errorCode: LIVR.ErrorCode = .wrongHex
        var arguments: Any?
        
        func isValid(_ string: [UInt8]) -> Bool {
            return Utils.isHex(string)
        }
    }
    
    /// the hex digest of one of the given algorithms
    struct Digest: FormatRule {
        static var name = "digest"
        var errorCode: LIVR.ErrorCode = .wrongDigest
        var arguments: Any?
        private var lengths = Set<Int>()
        
        mutating func prepare() throws {
            let lengthByAlgorithm = ["md5": 32, "sha1": 40, "sha256": 64, "sha384": 96, "sha512": 128]
            let algorithms = try allowedArguments(Set(lengthByAlgorithm.keys))
            guard !algorithms.isEmpty else { throw RuleGenerator.wrongArguments(Digest.name, arguments) }
            lengths = Set(algorithms.compactMap { lengthByAlgorithm[$0] })
        }
        
        func isValid(_ string: [UInt8]) -> Bool {
            return lengths.contains(string.count) && Utils.isHex(string)
        }
    }
    
    /// a BSON ObjectId
    struct MongoId: FormatRule {
        static var name = "mongo_id"
        var errorCode: LIVR.ErrorCode = .wrongMongoId
        var arguments: Any?
        
        func isValid(_ string: [UInt8]) -> Bool {
            return string.count == 24 && Utils.isHex(string)
        }
    }
    
    struct HexColor: FormatRule {
        static var name = "hex_color"
        var errorCode: LIVR.ErrorCode = .wrongHexColor
        var arguments: Any?
        
        func isValid(_ string: [UInt8]) -> Bool {
            return string.first == 0x23 && [4, 5, 7, 9].contains(string.count) && Utils.isHex(string.dropFirst())
        }
    }
    
    /// MAC-48 (EUI-48), or EUI-64 with { "mac": 64 }: pairs of hex digits separated by ":" or by "-"
    struct MAC: FormatRule {
        static var name = "mac"
        var errorCode: LIVR.ErrorCode = .wrongMac
        var arguments: Any?
        private var pairs = 6
        
        mutating func prepare() throws {
            let arguments = Utils.argumentsList(self.arguments)
            guard let bits = arguments.isEmpty ? 48 : Utils.nonNegativeInteger(arguments[0]), bits == 48 || bits == 64 else {
                throw RuleGenerator.wrongArguments(MAC.name, self.arguments)
            }
            pairs = bits / 8
        }
        
        func isValid(_ string: [UInt8]) -> Bool {
            guard string.count == pairs * 3 - 1, string[2] == colon || string[2] == dash else { return false }
            return string.indices.allSatisfy { $0 % 3 == 2 ? string[$0] == string[2] : Utils.isHex(string[$0]) }
        }
    }
    
    /// "+", then 7-15 digits, the first is not 0
    struct E164: FormatRule {
        static var name = "e164"
        var errorCode: LIVR.ErrorCode = .wrongE164
        var arguments: Any?
        
        func isValid(_ string: [UInt8]) -> Bool {
            let digits = string.dropFirst()
            return string.first == 0x2B && (7...15).contains(digits.count) && digits.first != 0x30 && Utils.isDigits(digits)
        }
    }
    
    /// Semantic Versioning 2.0.0, without a "v" prefix
    struct Semver: FormatRule {
        static var name = "semver"
        var errorCode: LIVR.ErrorCode = .wrongSemver
        var arguments: Any?
        
        func isValid(_ string: [UInt8]) -> Bool {
            guard string.allSatisfy({ $0 < 0x80 }), let string = String(bytes: string, encoding: .utf8) else { return false }
            return semverRegex.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count)) != nil
        }
    }
    
    /// the structure of the JWS compact serialization: three base64url segments, the signature may be empty
    struct JWT: FormatRule {
        static var name = "jwt"
        var errorCode: LIVR.ErrorCode = .wrongJwt
        var arguments: Any?
        
        func isValid(_ string: [UInt8]) -> Bool {
            let segments = string.split(separator: dot, omittingEmptySubsequences: false)
            guard segments.count == 3, !segments[0].isEmpty, !segments[1].isEmpty else { return false }
            return segments.allSatisfy { segment in
                segment.count % 4 != 1 && segment.allSatisfy { Utils.isLetter($0) || Utils.isDigit($0) || $0 == dash || $0 == 0x5F }
            }
        }
    }
    
    // MARK: - Checksums
    
    struct Luhn: FormatRule {
        static var name = "luhn"
        var errorCode: LIVR.ErrorCode = .wrongChecksum
        var arguments: Any?
        
        func isValid(_ string: [UInt8]) -> Bool {
            return string.count >= 2 && Utils.isDigits(string) && hasLuhnChecksum(string)
        }
    }
    
    /// 12-19 digits (ISO/IEC 7812) and the Luhn checksum
    struct CreditCard: FormatRule {
        static var name = "credit_card"
        var errorCode: LIVR.ErrorCode = .wrongCreditCardNumber
        var arguments: Any?
        
        func isValid(_ string: [UInt8]) -> Bool {
            return (12...19).contains(string.count) && Utils.isDigits(string) && hasLuhnChecksum(string)
        }
    }
    
    /// ISO 13616, without a per-country length table: the number modulo 97 is 1
    struct IBAN: FormatRule {
        static var name = "iban"
        var errorCode: LIVR.ErrorCode = .wrongIban
        var arguments: Any?
        
        func isValid(_ string: [UInt8]) -> Bool {
            let isUppercase = { (character: UInt8) in character >= 0x41 && character <= 0x5A }
            guard (15...34).contains(string.count), string[0..<2].allSatisfy(isUppercase), Utils.isDigits(string[2..<4]),
                string[4...].allSatisfy({ isUppercase($0) || Utils.isDigit($0) }) else { return false }
            
            // the first four characters move to the end, a letter is two digits: A = 10 ... Z = 35
            var remainder = 0
            for character in string[4...] + string[0..<4] {
                let number = Utils.isDigit(character) ? Int(character - 0x30) : Int(character - 0x41) + 10
                remainder = (remainder * (number < 10 ? 10 : 100) + number) % 97
            }
            return remainder == 1
        }
    }
}
