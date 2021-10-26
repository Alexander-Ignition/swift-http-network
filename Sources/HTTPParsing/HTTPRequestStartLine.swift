public struct HTTPRequestStartLine: Equatable, CustomStringConvertible {
    public let method: String
    public let target: String
    public let version: String

    public var description: String {
        "\(method) \(target) \(version)"
    }
}
