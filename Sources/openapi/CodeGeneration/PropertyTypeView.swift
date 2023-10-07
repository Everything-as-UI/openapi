//
//  File.swift
//  
//
//  Created by Denis Koryttsev on 7.10.23.
//

import Foundation
import OpenAPIKit30
import CoreUI
import DocumentUI
import SwiftLangUI

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
            case .object(_, _):
                propertyName.startsUppercased()
            case .array(_, let arrayContext):
                let item = arrayContext.items.map {
                    PropertyTypeView(schema: $0, propertyName: propertyName, inArray: true).erased
                } ?? "AnyCodable".erased
                "[\(item)]"
            case .all(let of, _):
                if of.count == 1 {
                    PropertyTypeView(schema: of[0], propertyName: propertyName, inArray: false).erased
                } else {
                    "TODO: untyped object"
                }
            case .one, .any:
                propertyName.startsUppercased()
            case .not(_, _):
                "Never"
            case .reference(let jSONReference, _):
                jSONReference.name.flatMap { config.models[$0]?.rename ?? $0 }?.startsUppercased() ?? "AnyCodable"
            case .fragment(_):
                "[String: String]" // TODO: empty object
            }
        }
    }
}
