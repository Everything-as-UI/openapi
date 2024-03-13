//
//  File.swift
//  
//
//  Created by Denis Koryttsev on 7.10.23.
//

import Foundation
import OpenAPIKit
import CoreUI
import DocumentUI
import SwiftLangUI

/// Should satisfy `IfUntypedObjectDeclView`
struct PropertyTypeView: TextDocument {
    let schema: JSONSchema
    let propertyName: String
    let inArray: Bool

    @Environment(\.config)
    private var config
    @Environment(\.configProperty)
    private var configProperty

    init(schema: JSONSchema, propertyName: String, inArray: Bool = false) {
        self.schema = schema
        self.propertyName = propertyName
        self.inArray = inArray
    }

    var textBody: some TextDocument {
        if let rename = configProperty.renameType {
            rename
        } else {
            switch schema.value {
            case .boolean(_):
                "Bool"
            case .number(_, _):
                "Decimal"
            case .integer(_, _):
                "Int"
            case .string(_, _):
                "String"
            case .object(_, let objectContext):
                if objectContext.properties.isEmpty, case .b(let additionalProperties) = objectContext.additionalProperties {
                    "[String: \(PropertyTypeView(schema: additionalProperties, propertyName: propertyName))]"
                } else {
                    propertyName.startsUppercased()
                }
            case .array(_, let arrayContext):
                let item = arrayContext.items.map {
                    PropertyTypeView(schema: $0, propertyName: propertyName, inArray: true).erased
                } ?? "AnyCodable".erased
                "[\(item)]"
            case .all(let of, _):
                if of.count == 1 {
                    PropertyTypeView(schema: of[0], propertyName: propertyName, inArray: false).erased
                } else {
                    "/*FIXME*/AnyCodable".erased
                }
            case .one(let of, _), .any(let of, _):
                let withoutNull = of.filter({ !$0.isNull })
                if withoutNull.count > 1 {
                    propertyName.startsUppercased()
                } else if !withoutNull.isEmpty {
                    PropertyTypeView(schema: withoutNull[0], propertyName: propertyName, inArray: false).erased
                } else {
                    "/*FIXME*/AnyCodable".erased
                }
            case .not(_, _):
                "AnyCodable"
            case .reference(let jSONReference, _):
                jSONReference.name.flatMap { config.models[$0]?.rename ?? $0 }?.startsUppercased() ?? "/*FIXME*/AnyCodable"
            case .fragment(_):
                "[String: String]" // TODO: empty object
            case .null:
                "/*FIXME*/NSNull" // TODO: handle it
            }
        }
    }
}
