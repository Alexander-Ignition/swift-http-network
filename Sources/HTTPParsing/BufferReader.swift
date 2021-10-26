import Foundation

struct BufferReader: CustomStringConvertible {
    var buffer: UnsafeMutableRawBufferPointer
    var startIndex: Int
    var endIndex: Int { buffer.endIndex }
    var isEmpty: Bool { startIndex == endIndex }

    init(buffer: UnsafeMutableRawBufferPointer) {
        self.buffer = buffer
        self.startIndex = buffer.startIndex
    }

    var description: String {
        string ?? "<invalid string>"
    }

    var string: String? {
        let slice = buffer[startIndex..<endIndex]
        let buffer = UnsafeMutableRawBufferPointer(rebasing: slice)
        return String(bytes: buffer, encoding: .ascii)
    }

    subscript(bounds: Range<Int>) -> BufferReader {
        let slice = buffer[bounds]
        let buffer = UnsafeMutableRawBufferPointer(rebasing: slice)
        return BufferReader(buffer: buffer)
    }

    @inlinable
    mutating func withReader(to bytes: [UInt8], block: (inout BufferReader) -> Bool) -> Bool {
        let originalIndex = startIndex
        guard var buffer = read(to: bytes) else {
            return false
        }
        let status = block(&buffer)
        if !status {
            startIndex = originalIndex
        }
        return status
    }

    func range(of bytes: [UInt8]) -> Range<Int>? {
        assert(!bytes.isEmpty)

        var startRangeIndex = startIndex
        var bytesIndex = bytes.startIndex
        var bufferIndex = startIndex

        while bufferIndex < endIndex {
            if bytesIndex == bytes.endIndex {
                return startRangeIndex..<bufferIndex
            }
            if bytesIndex == bytes.startIndex {
                startRangeIndex = bufferIndex
            }
            if buffer[bufferIndex] == bytes[bytesIndex] {
                bytes.formIndex(after: &bytesIndex)
            } else {
                bytesIndex = bytes.startIndex
            }
            buffer.formIndex(after: &bufferIndex)
        }
        return nil
    }

    mutating func read(to bytes: [UInt8]) -> BufferReader? {
        guard let bytesRange = range(of: bytes) else {
            return nil
        }
        let result = self[startIndex..<bytesRange.lowerBound]
        startIndex = bytesRange.upperBound
        return result
    }

    mutating func read(prefix: [UInt8]) -> Bool {
        assert(!prefix.isEmpty)
        guard buffer.count >= prefix.count else {
            return false
        }
        var index = startIndex
        for byte in prefix {
            if byte == buffer[index] {
                buffer.formIndex(after: &index)
            } else {
                return false
            }
        }
        startIndex = index
        return true
    }
}
