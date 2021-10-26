import Foundation

public struct HTTPHeaders {
    public static let `default`: HTTPHeaders = [
        .userAgent: "generic/1.0",
        .transferEncoding: "Identity",
        .connection: "close"
    ]

    public var fields: [Name: String]

    public init() {
        fields = [:]
    }

    public subscript(name: Name) -> String? {
        get {
            fields[name]
        }
        set {
            fields[name] = newValue
        }
    }

    public var contentLength: Int? {
        get {
            self[.contentLength].flatMap { Int($0) }
        }
        set {
            self[.contentLength] = newValue.map { "\($0)" }
        }
    }
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Name, String)...) {
        fields = Dictionary(elements, uniquingKeysWith: { _, new in new })
    }
}

extension HTTPHeaders: CustomStringConvertible {
    public var description: String {
        fields.map { name, value in
            "\(name): \(value)"
        }.joined(separator: "\r\n")
    }
}

// MARK: - HTTP Header Names

extension HTTPHeaders {
    public struct Name: RawRepresentable, Hashable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static let host = Name("Host")
        public static let userAgent = Name("User-Agent")
        public static let contentLength = Name("Content-Length")
        public static let accept = Name("Accept")
        public static let transferEncoding = Name("Transfer-Encoding")
        public static let connection = Name("Connection")
    }
}

extension HTTPHeaders.Name: CustomStringConvertible {
    public var description: String { rawValue }
}

extension HTTPHeaders.Name: LosslessStringConvertible {
    public init(_ description: String) {
        self.rawValue = description
    }
}

extension HTTPHeaders.Name: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = value
    }
}
