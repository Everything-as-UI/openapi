//
//  CommonExtensions.swift
//  
//
//  Created by Denis Koryttsev on 14.09.2023.
//

import Foundation

extension Sequence {
    func firstMap<R>(_ transform: (Element) -> R?) -> R? {
        for elem in self {
            guard let result = transform(elem) else { continue }
            return result
        }
        return nil
    }
}

extension String {
    var camelized: Self {
        guard !isEmpty else { return self }
        return components(separatedBy: CharacterSet.alphanumerics.inverted).reduce(into: "") { partialResult, part in
            if partialResult.isEmpty, !part.isEmpty {
                partialResult.append(part.startsLowercased())
            } else {
                partialResult.append(part.startsUppercased())
            }
        }
    }
}
