//
//  TypesFileView.swift
//  
//
//  Created by Denis Koryttsev on 7.10.23.
//

import Foundation
import OpenAPIKit
import CoreUI
import DocumentUI
import SwiftLangUI

struct TypesFileView: TextDocument {
    let document: OpenAPI.Document
    let imports: [String]

    @Environment(\.config)
    private var config

    var textBody: some TextDocument {
        """
        // Generated using `openapi-generator`
        // DO NOT EDIT
        """.endingWithNewline(2)
        ForEach(imports, separator: .newline) {
            "import \($0)"
        }.endingWithNewline()
        ForEach(
            document.components.schemas,
            separator: .newline
        ) { (key, schema) in
            let configModel = config.models[key.rawValue]
            let accessLevel = (configModel?.accessLevel ?? config.accessLevel)
                .flatMap(SwiftLangUI.Keyword.init(rawValue:)) ?? AccessLevelKey.defaultValue
            if (!config.filter && !(schema.deprecated && config.omitDeprecated)) || configModel?.inlined == false {
                let typeName = configModel?.rename ?? key.rawValue.startsUppercased()
                schema.description.commented(.newLineBlock).endingWithNewline()
                SchemaTypeView(schema: schema, typeName: typeName)
                    .environmentObject(document)
                    .environment(\.configModel, configModel ?? .default())
                    .environment(\.accessLevel, accessLevel)
            }
        }
    }
}
