//
//  IfUntypedObjectView.swift
//  
//
//  Created by Denis Koryttsev on 7.10.23.
//

import Foundation
import OpenAPIKit
import CoreUI
import DocumentUI
import SwiftLangUI

struct IfUntypedObjectDeclView: TextDocument {
    let schema: JSONSchema
    let typeName: String

    @Environment(\.accessLevel)
    private var accessLevel

    var textBody: some TextDocument {
        switch schema.value {
        case .object(let core, let objectContext):
            if objectContext.properties.isEmpty, case .b(let additionalProperties) = objectContext.additionalProperties {
                IfUntypedObjectDeclView(schema: additionalProperties, typeName: typeName).erased
            } else {
                ObjectView(typeName: typeName, object: objectContext, core: core)
            }
        case .array(_, let arrayContext):
            arrayContext.items.map { IfUntypedObjectDeclView(schema: $0, typeName: typeName).erased }
        case .one(let of, _), .any(let of, _):
            let withoutNull = of.filter({ !$0.isNull })
            if withoutNull.count > 1 {
                AssociatedEnumView(typeName: typeName, cases: of)
            } else if !withoutNull.isEmpty {
                IfUntypedObjectDeclView(schema: withoutNull[0], typeName: typeName).erased
            } else {
                NullDocument()
            }
        default: NullDocument()
        }
    }
}
