import Foundation
import HTTPNetwork

func newRequest() {
    let request = HTTPRequest(
        method: .GET,
        url: URL(string: "https://icanhazdadjoke.com/")!,
        headers: [
            .host: "icanhazdadjoke.com",
            .userAgent: "generic/1.0",
            .accept: "text/plain",
            .transferEncoding: "Identity",
            .connection :"close",
        ],
        body: nil)

    print()
    print(request)
    print()

    let queue = DispatchQueue(label: "http-connection-queue")
    let connection = HTTPConnection(
        request: request,
        queue: queue,
        completion: { result in
            print()
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error)
            }
            print()

            CFRunLoopStop(CFRunLoopGetMain())
        })

    connection.start()

    CFRunLoopRun()
}

newRequest()
