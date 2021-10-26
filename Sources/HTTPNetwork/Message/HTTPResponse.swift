import Foundation

public struct HTTPResponse {
    // TODO: add HTTPVersion, HTTPStatus(code, message),
    public var version: String
    public var statusCode: Int
    public var status: String
    public var headers: HTTPHeaders
    public var body: Data?

    public init(
        version: String = "1.1",
        statusCode: Int,
        status: String,
        headers: HTTPHeaders = [:],
        body: Data? = nil
    ) {
        self.version = version
        self.statusCode = statusCode
        self.status = status
        self.headers = headers
        self.body = body
    }
}

extension HTTPResponse: CustomStringConvertible {
    public var description: String {
        var text: [String] = [
            "\(version) \(statusCode) \(status)"
        ]
        if !headers.fields.isEmpty {
            text.append("\(headers)")
        }
        text.append("")
        if let string = body.flatMap({ String(data: $0, encoding: .utf8) }) {
            text.append(string)
        }
        return text.joined(separator: "\r\n")
    }
}
