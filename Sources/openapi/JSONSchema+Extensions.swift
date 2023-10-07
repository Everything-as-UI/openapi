//
//  File.swift
//  
//
//  Created by Denis Koryttsev on 27.08.2023.
//

import Foundation
import OpenAPIKit30

extension JSONSchema.Schema {
    
    var isOptional: Bool {
        switch self {
        case .boolean(let coreContext): return coreContext.nullable
        case .number(let coreContext, _): return coreContext.nullable
        case .integer(let coreContext, _): return coreContext.nullable
        case .string(let coreContext, _): return coreContext.nullable
        case .object(let coreContext, _): return coreContext.nullable
        case .array(let coreContext, _): return coreContext.nullable
        case .all(_, let core): return core.nullable
        case .one(_, let core): return core.nullable
        case .any(_, let core): return core.nullable
        case .not(_, _): return false
        case .reference(_, _): return false
        case .fragment(let coreContext): return coreContext.nullable
        }
    }
}

extension JSONSchema {
    func needsCodingKeys(document: OpenAPI.Document?) -> Bool {
        switch value {
        case .boolean(_): return false
        case .number(_, _): return false
        case .integer(_, _): return false
        case .string(_, _): return false
        case .object(_, let objectContext):
            return objectContext.needsCodingKeys()
        case .array(_, _): return false
        case .all(let of, _):
            return of.contains(where: { $0.needsCodingKeys(document: document) })
        case .one(_, _): return false
        case .any(_, _): return false
        case .not(_, _): return false
        case .reference(let jSONReference, _):
            return document
                .flatMap { try? $0.components.lookup(jSONReference) }
                .map { $0.needsCodingKeys(document: document) } ?? false
        case .fragment(_): return false
        }
    }
}

extension JSONSchema.ObjectContext {
    func needsCodingKeys() -> Bool {
        properties.keys.contains(where: { $0.hasPrefix("$") })
    }
    
    func withFilteredProperties(from configProperties: [String: Config.Model.Property]) -> Self {
        JSONSchema.ObjectContext(
            properties: OrderedDictionary(properties.filter({ configProperties[$0.key] != nil }), uniquingKeysWith: { $1 }),
            additionalProperties: additionalProperties,
            maxProperties: maxProperties,
            minProperties: minProperties)
    }
}

extension JSONSchema {
    func lookupDiscriminator(document: OpenAPI.Document?) -> OpenAPI.Discriminator? {
        switch value {
        case .boolean: return nil
        case .number: return nil
        case .integer: return nil
        case .string: return nil
        case .object(let context, _):
            return context.discriminator
        case .array: return nil
        case .all(let of, let context):
            return context.discriminator ?? of.compactMap { $0.lookupDiscriminator(document: document) }.first
        case .one(_, let context): return context.discriminator
        case .any(_, let context): return context.discriminator
        case .not(_, let context): return context.discriminator
        case .reference(let jSONReference, _):
            return document
                .flatMap { try? $0.components.lookup(jSONReference) }
                .flatMap { $0.lookupDiscriminator(document: document) }
        case .fragment(let context): return context.discriminator
        }
    }
}

extension JSONSchema {
    var reference: JSONReference<JSONSchema>? {
        guard case let .reference(ref, _) = value else { return nil }
        return ref
    }
}

extension DereferencedJSONSchema {
    func lookupDiscriminator() -> OpenAPI.Discriminator? {
        switch self {
        case .boolean: return nil
        case .number: return nil
        case .integer: return nil
        case .string: return nil
        case .object(let context, _):
            return context.discriminator
        case .array: return nil
        case .all(let of, let context):
            return context.discriminator ?? of.compactMap { $0.lookupDiscriminator() }.first
        case .one(_, let context): return context.discriminator
        case .any(_, let context): return context.discriminator
        case .not(_, let context): return context.discriminator
        case .fragment(let context): return context.discriminator
        }
    }
}
