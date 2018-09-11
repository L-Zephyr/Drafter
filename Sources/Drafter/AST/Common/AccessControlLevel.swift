//
// Created by LZephyr on 2018/9/8.
//

import Foundation

/// 访问权限，OC只有`public`和`private`
enum AccessControlLevel: Int, AutoCodable {
    case `private` = 0
    case `fileprivate` = 1
    case `internal` = 2
    case `public` = 3
    case `open` = 4
}

extension AccessControlLevel: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        switch value {
        case "open":
            self = .open
        case "public":
            self = .public
        case "internal":
            self = .internal
        case "fileprivate":
            self = .fileprivate
        case "private":
            self = .private
        default:
            self = .internal
        }
    }
}

extension AccessControlLevel: CustomStringConvertible {
    var description: String {
        switch self {
        case .open:
            return "open"
        case .public:
            return "public"
        case .internal:
            return "internal"
        case .fileprivate:
            return "fileprivate"
        case .private:
            return "private"
        }
    }
}

extension AccessControlLevel: Comparable {
    static func ==(_ lhs: AccessControlLevel, _ rhs: AccessControlLevel) -> Bool {
        switch (lhs, rhs) {
        case (.open, .open): fallthrough
        case (.public, .public): fallthrough
        case (.internal, .internal): fallthrough
        case (.fileprivate, .fileprivate): fallthrough
        case (.private, .private):
            return true
        default:
            return false
        }
    }

    static func <(_ lhs: AccessControlLevel, _ rhs: AccessControlLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}