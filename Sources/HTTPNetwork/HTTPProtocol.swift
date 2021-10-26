import Network

extension NWParameters {
    public static var http1: NWParameters {
        let parameters = NWParameters.tcp
        parameters.defaultProtocolStack.applicationProtocols.insert(HTTPProtocol.options, at: 0)
        return parameters
    }
}

public final class HTTPProtocolBase {}
public final class HTTPServerProtocol {}

public final class HTTPProtocol: NWProtocolFramerImplementation {
    public typealias Message = NWProtocolFramer.Message
    public typealias Options = NWProtocolFramer.Options

    public static let definition = NWProtocolFramer.Definition(implementation: HTTPProtocol.self)

    public static var options: Options {
        Options(definition: HTTPProtocol.definition)
    }

    public static func message() -> Message {
        Message(definition: definition)
    }

    public static func message(from context: NWConnection.ContentContext?) -> Message? {
        context?.protocolMetadata(definition: definition) as? Message
    }

    // MARK: - NWProtocolFramerImplementation

    public static let label = "HTTP/1.1"

    public init(framer: NWProtocolFramer.Instance) {
        print(#function, framer)
    }

    public func start(framer: NWProtocolFramer.Instance) -> NWProtocolFramer.StartResult {
        print(#function, framer)
        return .ready
    }

    public func wakeup(framer: NWProtocolFramer.Instance) {
        print(#function, framer)
    }

    public func stop(framer: NWProtocolFramer.Instance) -> Bool {
        print(#function, framer)
        return true
    }

    public func cleanup(framer: NWProtocolFramer.Instance) {
        print(#function, framer)
    }

    public func handleOutput(
        framer: NWProtocolFramer.Instance,
        message: NWProtocolFramer.Message,
        messageLength: Int,
        isComplete: Bool
    ) {
        guard let request = message.httpRequestHead else {
            return assertionFailure()
        }

        let head = request.encode(contentLength: messageLength)
        framer.writeOutput(data: head)

        do {
            try framer.writeOutputNoCopy(length: messageLength)
        } catch let error as NWError {
            framer.markFailed(error: error)
        } catch let error {
            assertionFailure("Unknown error: \(error)")
        }
    }

    public func handleInput(framer: NWProtocolFramer.Instance) -> Int {
        print(#function, framer)

//        let parsed = framer.parseInput(
//            minimumIncompleteLength: 64,
//            maximumLength: 1024,
//            parse: { (buffer: UnsafeMutableRawBufferPointer?, isComplete: Bool) -> Int in
//
//                guard let buffer = buffer else {
//                    return 0
//                }
//                return 0
//            })

        return 0
    }
}

extension NWProtocolFramer.Message {
    var httpRequestHead: HTTPRequestHead? {
        get {
            self[#function] as? HTTPRequestHead
        }
        set {
            self[#function] = newValue
        }
    }
}
