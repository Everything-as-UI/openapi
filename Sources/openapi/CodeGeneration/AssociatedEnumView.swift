//
//  AssociatedEnumView.swift
//  
//
//  Created by Denis Koryttsev on 7.10.23.
//

import Foundation
import OpenAPIKit
import CoreUI
import DocumentUI
import SwiftLangUI

struct AssociatedEnumView: TextDocument {
    let typeName: String
    let cases: [JSONSchema]

    @Environment(\.accessLevel)
    private var accessLevel
    @EnvironmentObject
    private var document: OpenAPI.Document
    @Environment(\.configModel)
    private var configModel
    @Environment(\.propertyNameResolver)
    private var propertyNameResolver

    var textBody: some TextDocument {
        TypeDecl(name: typeName, modifiers: [accessLevel, .enum], inherits: configModel.conformances).withBody {
            let discriminator = cases.firstMap({ $0.lookupDiscriminator(document: document) })
            ForEach(enumerated: cases, separator: .newline) { (i, schema) in
                let caseName = caseName(for: schema, discriminator: discriminator) ?? "case\(i)"
                "case \(caseName)(\(PropertyTypeView(schema: schema, propertyName: caseName)))"
                IfUntypedObjectDeclView(schema: schema, typeName: caseName.startsUppercased()).startingWithNewline()
            }
            if let discriminator {
                TypeDecl(name: "DiscriminatorKey", modifiers: [.private, .enum], inherits: ["String", "CodingKey"]).withBody {
                    "case discriminator = \"\(discriminator.propertyName)\""
                }.startingWithNewline()
                Function.initializer(args: [ClosureDecl.Arg(label: "from", argName: "decoder", type: "Decoder")], modifiers: [accessLevel], traits: [.throws]) {
                    """
                    let container = try decoder.container(keyedBy: DiscriminatorKey.self)
                    let discriminatorValue = try container.decode(String.self, forKey: .discriminator)
                    switch discriminatorValue {
                    """.endingWithNewline()
                    ForEach(enumerated: cases, separator: .newline) { (i, schema) in
                        let caseName = caseName(for: schema, discriminator: discriminator) ?? "case\(i)"
                        "case \"\(caseName)\": self = try .\(caseName)(\(PropertyTypeView(schema: schema, propertyName: caseName))(from: decoder))"
                    }.endingWithNewline()
                    "default: throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: \"Unexpected discriminator value\"))".endingWithNewline()
                    "}"
                }.startingWithNewline()
            }
        }
    }

    private func caseName(for schema: JSONSchema, discriminator: OpenAPI.Discriminator?) -> String? {
        switch schema.value {
        case .boolean: return "bool"
        case .number: return "decimal"
        case .integer: return "int"
        case .string: return "string"
        case .reference(let ref, _):
            return ref.name.flatMap { name in
                discriminator?.mapping?.firstMap({ $0.value.hasSuffix("/" + name) ? $0.key : nil })
            } ?? ref.name.map(propertyNameResolver)
        case .array(_, let arrayContext):
            return arrayContext.items.flatMap {
                caseName(for: $0, discriminator: nil).map { $0 + "Array" }
            }
        default:
            return nil
        }
    }
}
