import XCTest
@testable import openapi

final class openapiTests: XCTestCase {
    func processExample(at url: URL) throws {
        let generator = SchemasGenerator(url: url, config: nil)
        print(try generator.generateModels())
    }

    func testExample1() throws {
        let url = try XCTUnwrap(URL(string: "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/examples/v3.0/petstore.json"))
        try processExample(at: url)
    }

    func testExample2() throws {
        let url = try XCTUnwrap(URL(string: "https://github.com/OAI/OpenAPI-Specification/raw/main/examples/v3.0/uspto.json"))
        try processExample(at: url)
    }

    func testExample3() throws {
        let url = try XCTUnwrap(URL(string: "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/examples/v3.0/link-example.json"))
        try processExample(at: url)
    }

    func testExample4() throws {
        let url = try XCTUnwrap(URL(string: "https://api.apis.guru/v2/specs/ably.io/platform/1.1.0/openapi.json"))
        try processExample(at: url)
    }
}
