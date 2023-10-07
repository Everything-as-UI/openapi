//
//  RawRepresentableView.swift
//  
//
//  Created by Denis Koryttsev on 7.10.23.
//

import Foundation
import OpenAPIKit30
import CoreUI
import DocumentUI
import SwiftLangUI

struct RawRepresentableView: TextDocument {
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
        TypeDecl(name: typeName, modifiers: [accessLevel, .struct], inherits: ["RawRepresentable"] + configModel.conformances).withBody {
            "\(accessLevel) let rawValue: \(rawTypeName)".endingWithNewline()
            Function.initializer(args: [ClosureDecl.Arg(label: "rawValue", type: rawTypeName)], modifiers: [accessLevel]) {
                "self.rawValue = rawValue"
            }.endingWithNewline()
            ForEach(enumerated: allowedValues, separator: .newline) { (i, value) in
                "static let \(enumKey(for: value, index: i)) = Self(rawValue: \(enumValue(for: value) ?? "()"))"
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
