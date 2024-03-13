import Foundation
import OpenAPIKit30
import OpenAPIKit
import OpenAPIKitCompat
import Yams
import SwiftLangUI

// TODO: default value (custom init(decoder:))
// TODO: enums coding
// TODO: requests/responses
// TODO: encoding
// TODO: object type - additionalProperties
// TODO: anyOf not always enum, it can combine all available properties, needs to check it
// TODO: write tests

typealias DocumentV3_1 = OpenAPIKit.OpenAPI.Document
typealias DocumentV3_0 = OpenAPIKit30.OpenAPI.Document

public struct SchemasGenerator {
    let url: URL
    let config: Config?
    
    public init(url: URL, config: Config?) {
        self.url = url
        self.config = config
    }
    
    public func generateModels() throws -> String {
        let data = try Data(contentsOf: url)

        let document = try decode(from: data)
        
        let imports = config?.imports ?? []
        let accessLevel = config?.accessLevel.flatMap(SwiftLangUI.Keyword.init(rawValue:)) ?? AccessLevelKey.defaultValue
        let typesFile = TypesFileView(document: document, imports: ["Foundation"] + imports)
            .environment(\.allowedValuesRepresentation, .rawRepresentable)
            .environment(\.config, config ?? .default())
            .environment(\.accessLevel, accessLevel)
        return "\(typesFile)"
    }
}

public struct JSONSchemasGenerator {
    let url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    public func generate() throws -> String {
        let data = try Data(contentsOf: url)

        let document = try decode(from: data).locallyDereferenced()
        
        let typesFile = JSONTypesFileView(document: document)
            .environment(\.completeJSONView, true)
        return "\(typesFile)"
    }
}

private func decode(from data: Data) throws -> DocumentV3_1 {
    OpenAPIKit.VendorExtensionsConfiguration.isEnabled = false
    let decoder = YAMLDecoder()
    return try (try? decoder.decode(DocumentV3_0.self, from: data))?.to31()
    ?? decoder.decode(DocumentV3_1.self, from: data)
}
