//
//  IfUntypedObjectView.swift
//  
//
//  Created by Denis Koryttsev on 7.10.23.
//

import Foundation
import OpenAPIKit30
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
        case .object(_, let objectContext):
            ObjectView(typeName: typeName, object: objectContext)
        case .array(_, let arrayContext):
            arrayContext.items.map { IfUntypedObjectDeclView(schema: $0, typeName: typeName).erased }
        case .one(let of, _), .any(let of, _):
            AssociatedEnumView(typeName: typeName, cases: of)
        default: NullDocument()
        }
    }
}
