import XCTest
import OpenAPIKit
@testable import openapi

final class openapiTests: XCTestCase {

    func testExample1() throws {
        let url = try XCTUnwrap(URL(string: "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/examples/v3.0/petstore.json"))
        try processExample(at: url)
    }

    func testExample2() throws {
        let url = try XCTUnwrap(URL(string: "https://raw.githubusercontent.com/OAI/OpenAPI-Specification/main/examples/v3.0/uspto.json"))
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

    func testExample5() throws {
        let url = try XCTUnwrap(URL(string: "https://raw.githubusercontent.com/omarciovsena/abibliadigital/master/docs/openapi.yaml"))
        try processExample(at: url)
    }

    func testExample6() throws {
        VendorExtensionsConfiguration.isEnabled = false
        let url = try XCTUnwrap(URL(string: "https://api.opensanctions.org/openapi.json"))
        try processExample(at: url)
    }
}

private extension openapiTests {
    func processExample(at url: URL, expectedFileName: String = #function) throws {
        let generator = SchemasGenerator(url: url, config: nil)
        let result = try generator.generateModels()
        do {
            let bundleUrl = try XCTUnwrap(Bundle(for: type(of: self)).urls(forResourcesWithExtension: nil, subdirectory: nil)?[0])
            let bundle = try XCTUnwrap(Bundle(url: bundleUrl))
            let expectedFileUrl = try XCTUnwrap(bundle.url(forResource: String(expectedFileName.dropLast(2)), withExtension: nil))
            let expectedResult = try String(contentsOf: expectedFileUrl)
            XCTAssertEqual(result + "\n", expectedResult)
        } catch {
            XCTFail("Failed to compare with expected file. Reason: \(error)")
            print(result)
        }
    }
}
