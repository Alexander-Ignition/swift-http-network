public struct HTTPVersion: RawRepresentable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension HTTPVersion {
    public static let http1_0 = HTTPVersion("HTTP/1.0")
    public static let http1_1 = HTTPVersion("HTTP/1.1")
}

extension HTTPVersion: CustomStringConvertible {
    public var description: String { rawValue }
}

extension HTTPVersion: LosslessStringConvertible {
    public init(_ description: String) {
        self.rawValue = description
    }
}
