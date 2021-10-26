public struct HTTPResponseStatusLine: Equatable, CustomStringConvertible {
    public let version: String
    public let code: Int
    public let text: String

    public init(version: String, code: Int, text: String) {
        self.version = version
        self.code = code
        self.text = text
    }

    public var description: String {
        "\(version) \(code) \(text)"
    }
}
