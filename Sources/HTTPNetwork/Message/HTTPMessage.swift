import Foundation

struct HTTPMessage {
    struct RequestHead: CustomStringConvertible {
        let method: HTTPMethod
        let uri: String
        let version: HTTPVersion

        var description: String {
            "\(method) \(uri) \(version)"
        }
    }

    struct ResponseHead {
        let version: HTTPVersion
        let statusCode: Int
        let message: String
    }

    enum StatusLine {
        case request(RequestHead)
        case response(ResponseHead)
    }

    let statusLine: StatusLine
    let headers: [String: String]?
}

struct HTTPRequestHead {
    let version: HTTPVersion
    let method: HTTPMethod
    let uri: String
    let headers: [String: String]?

    func encode(contentLength: Int) -> Data {
        let message = [
            "\(method) \(uri) \(version)"
        ].joined(separator: "\n")
        return Data(message.utf8)
    }
}

struct HTTPResponseHead {
    let version: HTTPVersion
    let status: Int
    let headers: [String: String]?
}
