//
//  File.swift
//  
//
//  Created by Denis Koryttsev on 7.10.23.
//

import Foundation

public struct Config: Codable {
    let filter: Bool
    let accessLevel: String?
    let imports: [String]
    let models: [String: Model]

    struct Model: Codable {
        let rename: String?
        let filter: Bool
        let commentFiltered: Bool
        let accessLevel: String?
        let conformances: [String]
        let properties: [String: Property]

        struct Property: Codable, Hashable {
            let rename: String?
            let renameType: String?
            let optional: Bool?
        }
    }
}

extension Config {
    static func `default`() -> Self {
        Self(filter: false, accessLevel: nil, imports: [], models: [:])
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.filter = try container.decodeIfPresent(Bool.self, forKey: .filter) ?? false
        self.accessLevel = try container.decodeIfPresent(String.self, forKey: .accessLevel)
        self.imports = try container.decodeIfPresent([String].self, forKey: .imports) ?? []
        self.models = try container.decodeIfPresent([String: Config.Model].self, forKey: .models) ?? [:]
    }
}
extension Config.Model {
    static func `default`() -> Self {
        Self(rename: nil, filter: false, commentFiltered: false, accessLevel: nil, conformances: ["Codable"], properties: [:])
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.rename = try container.decodeIfPresent(String.self, forKey: .rename)
        self.filter = try container.decodeIfPresent(Bool.self, forKey: .filter) ?? false
        self.commentFiltered = try container.decodeIfPresent(Bool.self, forKey: .commentFiltered) ?? false
        self.accessLevel = try container.decodeIfPresent(String.self, forKey: .accessLevel)
        self.conformances = try container.decodeIfPresent([String].self, forKey: .conformances) ?? ["Codable"]
        self.properties = try container.decodeIfPresent([String: Property].self, forKey: .properties) ?? [:]
    }
}
extension Config.Model.Property {
    static func `default`() -> Self {
        Self(rename: nil, renameType: nil, optional: nil)
    }

    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            self.rename = try container.decodeIfPresent(String.self, forKey: .rename)
            self.renameType = try container.decodeIfPresent(String.self, forKey: .renameType)
            self.optional = try container.decodeIfPresent(Bool.self, forKey: .optional)
        } else {
            let singleContainer = try decoder.singleValueContainer()
            self.renameType = try singleContainer.decode(String.self)
            self.rename = nil
            self.optional = nil
        }
    }
}
