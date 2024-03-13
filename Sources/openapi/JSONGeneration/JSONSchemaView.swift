//
//  JSONSchemaView.swift
//  
//
//  Created by Denis Koryttsev on 27.08.2023.
//

import Foundation
import OpenAPIKit
import CoreUI
import DocumentUI
import SwiftLangUI

// TODO: values from `example`
// TODO: Correct discriminator property value

struct CompleteJSONViewKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

extension EnvironmentValues {
    var completeJSONView: Bool {
        set { self[CompleteJSONViewKey.self] = newValue }
        get { self[CompleteJSONViewKey.self] }
    }
}

struct JSONTypesFileView: TextDocument {
    let document: DereferencedDocument
    
    var textBody: some TextDocument {
        ForEach(
            document.components.schemas,
            separator: .newline
        ) { (key, schema) in
            if let derefSchema = try? schema.dereferenced(in: document.components) {
                schema.description.commented(.newLineBlock).endingWithNewline()
                let jsonName = key.rawValue.startsLowercased()
                "let \(jsonName) = \""
                JSONSchemaView(schema: derefSchema)
                "\""
            }
        }
    }
}

struct JSONSchemaView: TextDocument {
    let schema: DereferencedJSONSchema
    
    var textBody: some TextDocument {
        switch schema {
        case .boolean(_): "\(Bool.random())"
        case .number(_, _): "0.0"
        case .integer(_, _): "0"
        case .string(_, _): "\\\"string\\\""
        case .object(_, let objectContext):
            JSONObjectView(object: objectContext)
        case .array(_, let arrayContext):
            let value = arrayContext.items.map({ JSONSchemaView(schema: $0) }).erased
            "[\(value)]"
        case .all(let of, _):
            if of.count == 1 {
                JSONSchemaView(schema: of[0]).erased
            } else {
                "{"
                ForEach(of, separator: .comma) { schema in
                    JSONPropertiesView(schema: schema)
                }
                "}"
            }
        case .one(let of, _):
            JSONSchemaView(schema: of.randomElement() ?? of[0]).erased
        case .any(let of, _):
            JSONSchemaView(schema: of.randomElement() ?? of[0]).erased
        case .not(_, _):
            ""
        case .fragment:
            "{}"
        case .null:
            "null"
        }
    }
}

struct JSONObjectView: TextDocument {
    let object: DereferencedJSONSchema.ObjectContext
    
    var textBody: some TextDocument {
        "{"
        Properties(object: object)
        "}"
    }
    
    struct Properties: TextDocument {
        let object: DereferencedJSONSchema.ObjectContext
        
        @Environment(\.completeJSONView)
        private var completeJSONView
        
        var textBody: some TextDocument {
            ForEach(
                completeJSONView ? object.properties.map { $0 }
                : object.requiredProperties.compactMap { key in
                    object.properties[key].map { (key, $0) }
                },
                separator: .comma
            ) { property in
                "\\\"" + property.key + "\\\":"
                JSONSchemaView(schema: property.value)
            }
        }
    }
}

struct JSONPropertiesView: TextDocument {
    let schema: DereferencedJSONSchema

    var textBody: some TextDocument {
        switch schema {
        case .boolean(_): unexpectedSchema("boolean")
        case .number(_, _): unexpectedSchema("number")
        case .integer(_, _): unexpectedSchema("integer")
        case .string(_, _): unexpectedSchema("string")
        case .object(_, let objectContext):
            JSONObjectView.Properties(object: objectContext)
        case .array(_, _): unexpectedSchema("array")
        case .all(let of, _):
            ForEach(of, separator: .newline) { schema in
                JSONPropertiesView(schema: schema)
            }
        case .one(_, _): unexpectedSchema("oneOf")
        case .any(_, _): unexpectedSchema("anyOf")
        case .not(_, _): unexpectedSchema("not")
        case .fragment: NullDocument()
        case .null: unexpectedSchema("null")
        }
    }

    private func unexpectedSchema(_ name: String) -> NullDocument {
        print("Unexpected \(name) schema for properties")
        return NullDocument()
    }
}
