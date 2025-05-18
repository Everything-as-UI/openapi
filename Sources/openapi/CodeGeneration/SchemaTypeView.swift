//
//  SchemaTypeView.swift
//  
//
//  Created by Denis Koryttsev on 27.08.2023.
//

import Foundation
import OpenAPIKit
import CoreUI
import DocumentUI
import SwiftLangUI

struct SchemaTypeView: TextDocument {
    let schema: JSONSchema
    let typeName: String
    
    @EnvironmentObject
    private var document: OpenAPI.Document
    @Environment(\.accessLevel)
    private var accessLevel
    @Environment(\.config)
    private var config
    @Environment(\.configModel)
    private var configModel
    
    var textBody: some TextDocument {
        switch schema.value {
        case .boolean(let coreContext):
            "\(accessLevel) typealias " + typeName + " = Bool" + (coreContext.nullable ? "?" : "")
        case .number(let coreContext, _):
            AllowedValuesTypeView(typeName: typeName, rawTypeName: "Decimal", context: coreContext)
        case .integer(let coreContext, _):
            AllowedValuesTypeView(typeName: typeName, rawTypeName: "Int", context: coreContext)
        case .string(let coreContext, _):
            AllowedValuesTypeView(typeName: typeName, rawTypeName: "String", context: coreContext)
        case .object(let core, let objectContext):
            let filteredObject = configModel.filter ? objectContext.withFilteredProperties(from: configModel.properties) : nil
            ObjectView(typeName: typeName, object: filteredObject ?? objectContext, core: core)
        case .array(let coreContext, let arrayContext):
            let item = arrayContext.items.map({
                PropertyTypeView(schema: $0, propertyName: typeName.startsLowercased(), inArray: true).erased
            }) ?? "Any".erased
            let arrayDecl = "[\(item)]" + (coreContext.nullable ? "?" : "")
            "\(accessLevel) typealias " + typeName + " = " + arrayDecl
            arrayContext.items.map { IfUntypedObjectDeclView(schema: $0, typeName: typeName + "Item") }.startingWithNewline()
        case .all(let of, _):
            AllOfTypeView(typeName: typeName, of: of)
        case .one(let of, _), .any(let of, _):
            AssociatedEnumView(typeName: typeName, cases: of)
        case .not(_, _):
            "\(accessLevel) typealias " + typeName + " = Never"
        case .reference(let jSONReference, _):
            "\(accessLevel) typealias " + typeName + " = " + (jSONReference.name ?? "Any")
        case .fragment(let coreContext):
            "\(accessLevel) typealias " + typeName + " = [String: String]" + (coreContext.nullable ? "?" : "")
        case .null:
            "\(accessLevel) typealias " + typeName + " = NSNull"
        }
    }
}

struct PropertiesView: TextDocument {
    let schema: JSONSchema

    @EnvironmentObject
    private var document: OpenAPI.Document

    var textBody: some TextDocument {
        switch schema.value {
        case .boolean(_): unexpectedSchema("boolean")
        case .number(_, _): unexpectedSchema("number")
        case .integer(_, _): unexpectedSchema("integer")
        case .string(_, _): unexpectedSchema("string")
        case .object(_, let objectContext):
            ObjectView.Properties(object: objectContext)
        case .array(_, _): unexpectedSchema("array")
        case .all(let of, _):
            ForEach(of, separator: .newline) { schema in
                PropertiesView(schema: schema)
            }
        case .one(_, _): unexpectedSchema("oneOf")
        case .any(_, _): unexpectedSchema("anyOf")
        case .not(_, _): unexpectedSchema("not")
        case .reference(let jSONReference, _):
            (try? document.components.lookup(jSONReference))
                .map { PropertiesView(schema: $0).erased }
        case .fragment: NullDocument()
        case .null: NullDocument()
        }
    }

    @TextDocumentBuilder
    private func unexpectedSchema(_ name: String) -> some TextDocument {
        "Unexpected \(name) schema for properties".commented()
    }
}

struct CodingKeysView: TextDocument {
    let schema: JSONSchema

    @EnvironmentObject
    private var document: OpenAPI.Document

    var textBody: some TextDocument {
        switch schema.value {
        case .boolean(_): unexpectedSchema("boolean")
        case .number(_, _): unexpectedSchema("number")
        case .integer(_, _): unexpectedSchema("integer")
        case .string(_, _): unexpectedSchema("string")
        case .object(_, let objectContext):
            ObjectView.CodingKeysItems(object: objectContext)
        case .array(_, _): unexpectedSchema("array")
        case .all(let of, _):
            ForEach(of, separator: .newline) { schema in
                CodingKeysView(schema: schema)
            }
        case .one(_, _): unexpectedSchema("oneOf")
        case .any(_, _): unexpectedSchema("anyOf")
        case .not(_, _): unexpectedSchema("not")
        case .reference(let jSONReference, _):
            (try? document.components.lookup(jSONReference))
                .map { CodingKeysView(schema: $0).erased }
        case .fragment: NullDocument()
        case .null: NullDocument()
        }
    }

    @TextDocumentBuilder
    private func unexpectedSchema(_ name: String) -> some TextDocument {
        "Unexpected \(name) schema for properties".commented()
    }
}

struct AllowedValuesTypeView: TextDocument {
    let typeName: String
    let rawTypeName: String
    let context: JSONSchemaContext
    
    @Environment(\.accessLevel)
    private var accessLevel
    @Environment(\.allowedValuesRepresentation)
    private var allowedValuesRepresentation
    
    var textBody: some TextDocument {
        switch allowedValuesRepresentation {
        case .enum where context.allowedValues?.isEmpty == false:
            EnumView(typeName: typeName, rawTypeName: rawTypeName, allowedValues: context.allowedValues!)
        case .rawRepresentable where context.allowedValues?.isEmpty == false:
            RawRepresentableView(typeName: typeName, rawTypeName: rawTypeName, allowedValues: context.allowedValues!)
        default:
            "\(accessLevel) typealias " + typeName + " = " + rawTypeName + (context.nullable ? "?" : "")
        }
    }
}

struct AllOfTypeView: TextDocument {
    let typeName: String
    let of: [JSONSchema]
    
    @EnvironmentObject
    private var document: OpenAPI.Document
    @Environment(\.accessLevel)
    private var accessLevel
    @Environment(\.configModel)
    private var configModel
    
    var textBody: some TextDocument {
        TypeDecl(name: typeName, modifiers: [accessLevel, .struct], inherits: configModel.conformances).withBody {
            ForEach(of, separator: .newline) { schema in
                PropertiesView(schema: schema)
            }
            if of.contains(where: { $0.needsCodingKeys(document: document) }) {
                TypeDecl(name: "CodingKeys", modifiers: [.private, .enum], inherits: ["String", "CodingKey"]).withBody {
                    ForEach(of, separator: .newline) { schema in
                        CodingKeysView(schema: schema)
                    }
                }.startingWithNewline()
            }
        }
    }
}
