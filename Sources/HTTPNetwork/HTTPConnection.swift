import Foundation
import HTTPParsing
import Network

public enum HTTPConnectionError: Error {
    case cannotParseResponse
    case network(NWError)
    case cancelled
    case unknown
}

public final class HTTPConnection {
    /// Network connection.
    ///
    /// - Precondition: Do not change `connection.stateUpdateHandler`.
    public let connection: NWConnection

    /// Completion and work queue.
    ///
    /// - Precondition: Should be serial.
    public let queue: DispatchQueue

    /// A new `HTTPConnection`.
    ///
    /// - Parameters:
    ///   - connection: Data connection.
    ///   - queue: Connection events queue.
    public init(connection: NWConnection, queue: DispatchQueue) {
        self.connection = connection
        self.queue = queue
    }

    /// Current TCP options. Readonly.
    public var tcp: NWProtocolTCP.Options? {
        connection.parameters.defaultProtocolStack.internetProtocol as? NWProtocolTCP.Options
    }

    /// Current TLS options. Readonly.
    public var tls: NWProtocolTLS.Options? {
        connection.parameters.defaultProtocolStack.applicationProtocols.first as? NWProtocolTLS.Options
    }

    public func start() {
        connection.start(queue: queue)
    }

    public func cancel() {
        connection.cancel()
    }
}

// MARK: - HTTP client

extension HTTPConnection {
    public typealias ResponseCompletion = (Result<HTTPResponse, HTTPConnectionError>) -> Void

    public convenience init(
        request: HTTPRequest,
        tcp: NWProtocolTCP.Options = NWProtocolTCP.Options(),
        tls: NWProtocolTLS.Options? = nil,
        queue: DispatchQueue,
        completion: @escaping ResponseCompletion
    ) {
        var tls = tls
        if request.url.scheme == "https", tls == nil {
            /// Required for secure connection
            tls = NWProtocolTLS.Options()
        }
        let endpoint = NWEndpoint.url(request.url)
        let parameters = NWParameters(tls: tls, tcp: tcp)
        let connection = NWConnection(to: endpoint, using: parameters)

        self.init(request: request, connection: connection, queue: queue, completion: completion)
    }

    public convenience init(request: HTTPRequest,
         connection: NWConnection,
         queue: DispatchQueue,
         completion: @escaping ResponseCompletion
    ) {
        self.init(connection: connection, queue: queue)

        connection.stateUpdateHandler = { state in
            switch state {
            case .setup:
                break
            case .waiting(let error):
                completion(.failure(.network(error)))
            case .preparing:
                break
            case .ready:
                let data = request.string.data(using: .ascii)!
                connection.send(content: data, completion: .contentProcessed { error in
                    if let error = error {
                        print(error)
                    }
                })
            case .failed(let error):
                completion(.failure(.network(error)))
            case .cancelled:
                completion(.failure(.cancelled))
            @unknown default:
                completion(.failure(.unknown))
            }
        }

        var response: HTTPResponse?
        let httpParser = HTTPParser(startLineHandler: .response { statusLine in
            response = HTTPResponse(
                version: statusLine.version,
                statusCode: statusLine.code,
                status: statusLine.text
            )
        }, headerFieldHandler: { name, value in
            response?.headers.fields[HTTPHeaders.Name(name)] = value
        })

        connection.receiveMessage { [completion] data, context, isComplete, error in
            guard error == nil else {
                return // catch error in `stateDidUpdate(_:)`
            }
            guard var data = data else {
                return completion(.failure(.cannotParseResponse))
            }
            let count = data.withUnsafeMutableBytes { buffer in
                httpParser.parse(buffer: buffer)
            }
            guard var response = response else {
                return completion(.failure(.cannotParseResponse))
            }
            if count < data.count {
                response.body = data[count...]
            }
            completion(.success(response))
        }
    }
}
