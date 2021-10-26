extension String {
    var bytes: [UInt8] {
        unicodeScalars.map { UInt8(ascii: $0) }
    }
}

extension Array where Element == UInt8 {
    static let newLine = "\r\n".bytes
    static let headerSeparator = ": ".bytes
    static let whitespace = " ".bytes
}

public final class HTTPParser {
    public typealias RequestStartLineHandler = (HTTPRequestStartLine) -> Void
    public typealias ResponseStatusLineHandler = (HTTPResponseStatusLine) -> Void
    public typealias HeaderFieldHandler = (String, String) -> Void

    public enum StartLineHander {
        case request(RequestStartLineHandler)
        case response(ResponseStatusLineHandler)
    }

    public enum State {
        case startLine
        case headers
        case body
    }

    public private(set) var state: State = .startLine
    public private(set) var length: Int = 0

    public let startLineHandler: StartLineHander
    public let headerFieldHandler: HeaderFieldHandler

    public init(
        startLineHandler: StartLineHander,
        headerFieldHandler: @escaping HeaderFieldHandler
    ) {
        self.startLineHandler = startLineHandler
        self.headerFieldHandler = headerFieldHandler
    }

    public func parse(buffer: UnsafeMutableRawBufferPointer) -> Int {
        var reader = BufferReader(buffer: buffer)

        switch state {
        case .startLine:
            guard _parseStartLine(&reader) else {
                return 0
            }
            state = .headers
            fallthrough
        case .headers:
            while _parseHeaderField(&reader) {
                // next header field
            }
            if reader.read(prefix: .newLine) {
                state = .body
            }
        case .body:
            break
        }
        length += reader.startIndex
        return reader.startIndex
    }

    private func _parseStartLine(_ reader: inout BufferReader) -> Bool {
        guard var startLine = reader.read(to: .newLine) else {
            return false
        }
        switch startLineHandler {
        case .request(let requestStartLineHandler):
            if let request = _parseRequestStartLine(&startLine) {
                requestStartLineHandler(request)
                return true
            }
        case .response(let responseStatusLineHandler):
            if let response = _parseResponseStatusLine(&startLine) {
                responseStatusLineHandler(response)
                return true
            }
        }
        return false
    }

    /// `<method> <target> <version>\r\n`
    private func _parseRequestStartLine(_ reader: inout BufferReader) -> HTTPRequestStartLine? {
        guard let method = reader.read(to: .whitespace)?.string else {
            return nil
        }
        guard let target = reader.read(to: .whitespace)?.string else {
            return nil
        }
        guard let version = reader.string else {
            return nil
        }
        return HTTPRequestStartLine(method: method, target: target, version: version)
    }

    /// `<version> <code> <status>\r\n`
    private func _parseResponseStatusLine(_ reader: inout BufferReader) -> HTTPResponseStatusLine? {
        guard let version = reader.read(to: .whitespace)?.string else {
            return nil
        }
        guard let code = reader.read(to: .whitespace)?.string else {
            return nil
        }
        guard let text = reader.string else {
            return nil
        }
        return HTTPResponseStatusLine(version: version, code: Int(code)!, text: text)
    }

    /// `<name>: <value>\r\n`
    private func _parseHeaderField(_ reader: inout BufferReader) -> Bool  {
        reader.withReader(to: .newLine) { line in
            guard let name = line.read(to: .headerSeparator)?.string else {
                return false
            }
            guard let value = line.string else {
                return false
            }
            headerFieldHandler(name, value)
            return true
        }
    }
}
