import Foundation
import Network
import os.log

public final class HTTPServer {
    public let listener: NWListener
    public let queue: DispatchQueue

    private let logger: Logger = Logger(subsystem: "http", category: "server")

    private var connectionIdentifier = 0
    private var connections: [Int: HTTPConnection] = [:]

    init(listener: NWListener, queue: DispatchQueue) {
        self.listener = listener
        self.queue = queue
    }

    func listen(
        using parameters: NWParameters = .tcp,
        on port: NWEndpoint.Port = .http
    ) throws {
        let listener = try NWListener(using: parameters, on: port)
        listener.stateUpdateHandler = { [logger] state in
            switch state {
            case .setup:
                logger.debug("server setup")
            case .waiting(let error):
                logger.warning("server waiting \(error.debugDescription)")
            case .ready:
                logger.debug("server ready")
            case .failed(let error):
                logger.error("server failed: \(error.debugDescription)")
            case .cancelled:
                logger.debug("server cancelled")
            @unknown default:
                logger.error("server unknown state")
            }
        }
        listener.newConnectionHandler = { [weak self] newConnection in
            self?.addConnection(newConnection)
        }
        listener.start(queue: queue)
    }

    private func addConnection(_ newConnection: NWConnection) {
        let queue = DispatchQueue(
            label: "http-connection-queue-\(connectionIdentifier)",
            target: self.queue
        )
        let connection = HTTPConnection(
            connection: newConnection,
            queue: queue
        )
        connectionIdentifier += 1
        connections[connectionIdentifier] = connection
        connection.start()
    }
}

