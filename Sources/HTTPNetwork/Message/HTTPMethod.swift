public struct HTTPMethod: RawRepresentable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension HTTPMethod {
    public static let GET = HTTPMethod("GET")
    public static let POST = HTTPMethod("POST")
}

extension HTTPMethod: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension HTTPMethod: LosslessStringConvertible {
    public init(_ description: String) {
        self.rawValue = description
    }
}

extension HTTPMethod: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}
