//
//  File.swift
//  
//
//  Created by Denis Koryttsev on 7.10.23.
//

import Foundation
import CoreUI
import SwiftLangUI
import OpenAPIKit

enum PropertyNameResolverKey: EnvironmentKey {
    static var defaultValue: (_ key: String) -> String = { key in
        let camelizedKey = key.camelized
        return Keyword(rawValue: camelizedKey).map { _ in "`\(camelizedKey)`" } ?? camelizedKey
    }
}
enum AccessLevelKey: EnvironmentKey {
    static let defaultValue: SwiftLangUI.Keyword = .public
}
enum AllowedValuesRepresentation: EnvironmentKey {
    case `typealias`
    case `enum`
    case rawRepresentable

    static let defaultValue: Self = .typealias
}
enum ConfigKey: EnvironmentKey {
    static let defaultValue: Config = .default()
}
enum ConfigModelKey: EnvironmentKey {
    static let defaultValue: Config.Model = .default()
}
enum ConfigPropertyKey: EnvironmentKey {
    static let defaultValue: Config.Model.Property = .default()
}

extension EnvironmentValues {
    var propertyNameResolver: (String) -> String {
        set { self[PropertyNameResolverKey.self] = newValue }
        get { self[PropertyNameResolverKey.self] }
    }
    var accessLevel: SwiftLangUI.Keyword {
        set { self[AccessLevelKey.self] = newValue }
        get { self[AccessLevelKey.self] }
    }
    var allowedValuesRepresentation: AllowedValuesRepresentation {
        set { self[AllowedValuesRepresentation.self] = newValue }
        get { self[AllowedValuesRepresentation.self] }
    }
    var config: Config {
        set { self[ConfigKey.self] = newValue }
        get { self[ConfigKey.self] }
    }
    var configModel: Config.Model {
        set { self[ConfigModelKey.self] = newValue }
        get { self[ConfigModelKey.self] }
    }
    var configProperty: Config.Model.Property {
        set { self[ConfigPropertyKey.self] = newValue }
        get { self[ConfigPropertyKey.self] }
    }
}
