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
    @Environment(\.config)
    private var config
    @EnvironmentObject<DocumentV3_1>
    private var document

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
        case .all(let of, _):
            if of.count == 1 {
                IfUntypedObjectDeclView(schema: of[0], typeName: typeName).erased
            } else {
                AllOfTypeView(typeName: typeName, of: of)
            }
        case .reference(let ref, _):
            let configModel = ref.name.flatMap { config.models[$0] }
            if let configModel, configModel.inlined {
                let name = ref.name.map { configModel.rename ?? $0 }?.startsUppercased() ?? typeName
                (try? document.components.lookup(ref))
                    .map { IfUntypedObjectDeclView(schema: $0, typeName: name).erased }
            }
        default: NullDocument()
        }
    }
}
