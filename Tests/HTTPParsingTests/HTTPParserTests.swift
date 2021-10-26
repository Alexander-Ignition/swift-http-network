import HTTPParsing
import XCTest

// GET / HTTP/1.1
// Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
// Accept-Encoding: gzip, deflate, br
// Host: news.ycombinator.com
// User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15
// Accept-Language: ru
// Referer: https://yandex.ru/search/?clid=1906725&text=hacker+news&lr=213&redircnt=1631195967.1
// Connection: keep-alive

final class HTTPParserTests: XCTestCase {

    func testParseResponseFromOneBuffer() {
        let response = [
            "HTTP/1.1 200 OK",
            "Content-Type: text/html; charset=utf-8",
            "Content-Encoding: gzip",
            "Transfer-Encoding: Identity",
            "",
            "<p>Hello</p>",
        ].joined(separator: "\r\n")

        var responseLine: HTTPResponseStatusLine?
        var headers = HTTPHeaders()

        let parser = HTTPParser(startLineHandler: .response { response in
            responseLine = response
        }, headerFieldHandler: { name, value in
            headers.add(name: name, value: value)
        })

        var data = Data(response.utf8)
        data.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) in
            XCTAssertEqual(parser.parse(buffer: buffer), 112)
        }
        XCTAssertEqual(parser.state, .body)
        XCTAssertEqual(parser.length, 112)
        XCTAssertEqual(responseLine, HTTPResponseStatusLine(version: "HTTP/1.1", code: 200, text: "OK"))
        XCTAssertEqual(headers, [
            "Content-Type": "text/html; charset=utf-8",
            "Content-Encoding": "gzip",
            "Transfer-Encoding": "Identity"
        ])
        XCTAssertEqual(String(data: data[112...], encoding: .utf8)!, "<p>Hello</p>")
    }

    func testParseResponseFromManyBuffers() {
        let response = [
            "HTTP/1.1 200 OK",
            "Content-Type: text/html; charset=utf-8",
            "Content-Encoding: gzip",
            "Transfer-Encoding: Identity",
            "",
            "<html></html>",
        ].joined(separator: "\r\n")

        var responseLine: HTTPResponseStatusLine?
        var headers = HTTPHeaders()

        let parser = HTTPParser(startLineHandler: .response { response in
            responseLine = response
        }, headerFieldHandler: { name, value in
            headers.add(name: name, value: value)
        })

        var data = Data(response.utf8)
        data.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) in
            XCTAssertEqual(parser.state, .startLine)
            XCTAssertEqual(parser.parse(buffer: buffer[rebasing: 0..<5]), 0, "too small")
            XCTAssertEqual(parser.state, .startLine)
            XCTAssertEqual(parser.parse(buffer: buffer[rebasing: 0..<20]), 17, "Response status line")

            XCTAssertEqual(parser.state, .headers)
            XCTAssertEqual(parser.parse(buffer: buffer[rebasing: 17..<64]), 40)
            XCTAssertEqual(parser.state, .headers)
            XCTAssertEqual(parser.parse(buffer: buffer[rebasing: 57..<64]), 0, "too small")
            XCTAssertEqual(parser.state, .headers)
            XCTAssertEqual(parser.parse(buffer: buffer[rebasing: 57..<100]), 24, "Content-Encoding")
            XCTAssertEqual(parser.state, .headers)
            XCTAssertEqual(parser.parse(buffer: buffer[rebasing: 81..<112]), 31, "Transfer-Encoding + headers end")
            XCTAssertEqual(parser.state, .body)
        }
        XCTAssertEqual(parser.length, 112, "Status line with headers length")
        XCTAssertEqual(responseLine, HTTPResponseStatusLine(version: "HTTP/1.1", code: 200, text: "OK"))
        XCTAssertEqual(headers, [
            "Content-Type": "text/html; charset=utf-8",
            "Content-Encoding": "gzip",
            "Transfer-Encoding": "Identity"
        ])
    }
}

extension UnsafeMutableRawBufferPointer {
    subscript(rebasing bounds: Range<Int>) -> UnsafeMutableRawBufferPointer {
        UnsafeMutableRawBufferPointer(rebasing: self[bounds])
    }
}
