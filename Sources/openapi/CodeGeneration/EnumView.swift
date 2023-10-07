//
//  EnumView.swift
//  
//
//  Created by Denis Koryttsev on 7.10.23.
//

import Foundation
import OpenAPIKit30
import CoreUI
import DocumentUI
import SwiftLangUI

struct EnumView: TextDocument {
    let typeName: String
    let rawTypeName: String
    let allowedValues: [AnyCodable]

    @Environment(\.accessLevel)
    private var accessLevel
    @Environment(\.configModel)
    private var configModel

    @Environment(\.propertyNameResolver)
    private var propertyNameResolver

    var textBody: some TextDocument {
        TypeDecl(name: typeName, modifiers: [accessLevel, .enum], inherits: [rawTypeName] + configModel.conformances).withBody {
            ForEach(enumerated: allowedValues, separator: .newline) { (i, value) in
                "case \(enumKey(for: value, index: i))"
                enumValue(for: value).prefix(" = ")
            }
        }
    }

    private func enumKey(for value: AnyCodable, index: Int) -> String {
        switch value.value {
        case let string as String: return propertyNameResolver(string)
        default: return "case\(index)"
        }
    }

    private func enumValue(for value: AnyCodable) -> String? {
        switch value.value {
        case let string as String: return "\"\(string)\""
        case let int as Int: return String(int)
        case let uint as UInt: return String(uint)
        default: return nil
        }
    }
}
