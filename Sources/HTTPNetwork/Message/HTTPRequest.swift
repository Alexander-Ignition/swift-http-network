import Foundation

public struct HTTPRequest {
    public var version: HTTPVersion
    public var method: HTTPMethod
    public var url: URL
    public var headers: HTTPHeaders
    public var body: Data?

    public init(
        version: HTTPVersion = .http1_0,
        method: HTTPMethod,
        url: URL,
        headers: HTTPHeaders = [:],
        body: Data? = nil
    ) {
        self.version = version
        self.method = method
        self.url = url
        self.headers = headers
        self.body = body
    }

    public var string: String {
        // check path
        // check Host
        var lines: [String] = [
            "\(method) \(url.path) \(version)" // query and anchor ?
        ]
        if !headers.fields.isEmpty {
            lines.append(contentsOf: headers.fields.map { key, value in
                "\(key): \(value)"
            })
        }
        lines.append(contentsOf: ["", ""])
        return lines.joined(separator: "\r\n")
    }
}

extension HTTPRequest: CustomStringConvertible {
    public var description: String {
        var lines: [String] = [
            "\(method) \(url.path) \(version)"
        ]
        if !headers.fields.isEmpty {
            lines.append("\(headers)")
        }
        return lines.joined(separator: "\r\n")
    }
}
