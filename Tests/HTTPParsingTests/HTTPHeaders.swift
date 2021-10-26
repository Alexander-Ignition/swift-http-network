/// Ordered HTTP headers.
struct HTTPHeaders {
    typealias Field = (name: String, value: String)

    var fields: [Field] = []

    mutating func add(name: String, value: String) {
        fields.append(Field(name, value))
    }
}

extension HTTPHeaders: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (String, String)...) {
        fields = elements
    }
}

extension HTTPHeaders: Equatable {
    static func == (left: HTTPHeaders, right: HTTPHeaders) -> Bool {
        guard left.fields.count == right.fields.count else {
            return false
        }
        return zip(left.fields, right.fields).allSatisfy { filed1, filed2 in
            filed1.name == filed2.name && filed1.value == filed2.value
        }
    }
}
