//
//  ObjectView.swift
//  
//
//  Created by Denis Koryttsev on 7.10.23.
//

import Foundation
import OpenAPIKit30
import CoreUI
import DocumentUI
import SwiftLangUI

struct ObjectView: TextDocument {
    let typeName: String
    let object: JSONSchema.ObjectContext

    @Environment(\.accessLevel)
    private var accessLevel
    @Environment(\.configModel)
    private var configModel

    var textBody: some TextDocument {
        TypeDecl(name: typeName, modifiers: [accessLevel, .struct], inherits: configModel.conformances).withBody {
            Properties(object: object)
            if object.properties.contains(where: { $0.hasPrefix("$") }) { // TODO: not only $
                TypeDecl(name: "CodingKeys", modifiers: [.private, .enum], inherits: ["String", "CodingKey"]).withBody {
                    CodingKeysItems(object: object)
                }.startingWithNewline()
            }
        }
    }

    @Environment(\.propertyNameResolver)
    private static var propertyNameResolver

    struct Properties: TextDocument {
        let object: JSONSchema.ObjectContext

        @Environment(\.accessLevel)
        private var accessLevel
        @Environment(\.configModel)
        private var configModel

        var textBody: some TextDocument {
            ForEach(object.properties, separator: .newline) { property in
                let configProperty = configModel.properties[property.key, default: .default()]
                let propertyName = configProperty.rename ?? ObjectView.propertyNameResolver(property.key)
                property.value.coreContext?.description.commented(.line(documented: true)).endingWithNewline()
                if property.value.deprecated {
                    "@available(*, deprecated)".endingWithNewline()
                }
                "\(accessLevel) let " + propertyName + ": "
                PropertyTypeView(schema: property.value, propertyName: propertyName)
                    .environment(\.configProperty, configProperty)
                ifOptional(property.value, key: property.key, configProperty: configProperty)
                IfUntypedObjectDeclView(schema: property.value, typeName: ObjectView.propertyNameResolver(property.key).startsUppercased()).startingWithNewline()
            }
        }

        private func ifOptional(_ property: JSONSchema, key: String, configProperty: Config.Model.Property) -> String {
            let isOptional = configProperty.optional ?? !object.requiredProperties.contains(key)
            guard isOptional else { return "" }
            return "?"
        }
    }

    struct CodingKeysItems: TextDocument {
        let object: JSONSchema.ObjectContext

        var textBody: some TextDocument {
            ForEach(object.properties.keys, separator: .newline) { key in
                "case " + ObjectView.propertyNameResolver(key) + " = " + "\"\(key)\""
            }
        }
    }
}
