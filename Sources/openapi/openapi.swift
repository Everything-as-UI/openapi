import Foundation
import OpenAPIKit30
import Yams
import SwiftLangUI

// TODO: default value (custom init(decoder:))
// TODO: requests/responses
// TODO: encoding
// TODO: object type - additionalProperties

public struct SchemasGenerator {
    let url: URL
    let config: Config?
    
    public init(url: URL, config: Config?) {
        self.url = url
        self.config = config
    }
    
    public func generateModels() throws -> String {
        let data = try Data(contentsOf: url)
        
        let decoder = YAMLDecoder()
        let document = try decoder.decode(OpenAPI.Document.self, from: data)
        
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
        
        let decoder = YAMLDecoder()
        let document = try decoder.decode(OpenAPI.Document.self, from: data).locallyDereferenced()
        
        let typesFile = JSONTypesFileView(document: document)
            .environment(\.completeJSONView, true)
        return "\(typesFile)"
    }
}
