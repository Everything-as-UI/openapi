//
//  main.swift
//  
//
//  Created by Denis Koryttsev on 09.09.2023.
//

import Foundation
import openapi
import Yams

guard CommandLine.arguments.count > 1 else {
    print("missing file argument")
    exit(0)
}
let jsonArgIndex = CommandLine.arguments.firstIndex(of: "--json").map {
    CommandLine.arguments.remove(at: $0)
}
let configUrl = CommandLine.arguments.firstIndex(where: { $0.hasSuffix(".yml") || $0.hasSuffix(".yaml") }).map {
    CommandLine.arguments.remove(at: $0)
}.map(URL.init(fileURLWithPath:))
let url = CommandLine.arguments.last.map(URL.init(fileURLWithPath:))

guard let url else {
    print("can't access to file", url?.path ?? "")
    exit(0)
}

if jsonArgIndex != nil {
    let jsonGenerator = JSONSchemasGenerator(url: url)
    print(try jsonGenerator.generate())
} else {
    let config = try configUrl.map { try YAMLDecoder().decode(Config.self, from: Data(contentsOf: $0)) }
    let generator = SchemasGenerator(url: url, config: config)
    print(try generator.generateModels())
}
